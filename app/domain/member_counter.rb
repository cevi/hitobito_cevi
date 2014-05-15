class MemberCounter

  # Groups not appearing here are not counted at all.
  TOP_LEVEL = [
    Group::Sport,
    Group::Jungschar,
    Group::TenSing,
    Group::WeitereArbeitsgebiete,
  ]
  GROUPS = TOP_LEVEL + [
    Group::SportTeamGruppe,
    Group::WeitereArbeitsgebieteTeamGruppe,
    Group::Froeschli,
    Group::Stufe,
    Group::Gruppe,
    Group::JungscharTeam,
    Group::TenSingTeamGruppe
  ]

  IGNORED_ROLE_NAMES = [
    'FreierMitarbeiter'
  ]

  attr_reader :year, :group

  class << self
    def filtered_roles
      GROUPS.map(&:roles).flatten.reject do |role|
        role_name = role.to_s.demodulize.split('::').last
        role_name =~ /#{IGNORED_ROLE_NAMES.join('|')}/
      end

    end
    def create_counts_for(group)
      census = Census.current
      if census && !current_counts?(group, census)
        new(census.year, group).count!
        census.year
      else
        false
      end
    end

    def current_counts?(group, census = Census.current)
      census && new(census.year, group).exists?
    end

    def counted_roles
      ROLE_MAPPING.values.flatten
    end
  end

  ROLE_MAPPING = { person: filtered_roles }

  # create a new counter for with the given year and group.
  # beware: the year is only used to store the results and does not
  # specify which roles to consider - only currently not deleted roles are counted.
  def initialize(year, group)
    @year = year
    @group = group
  end

  def count!
    MemberCount.transaction do
      count.save!
    end
  end

  def count
    count = new_member_count
    count_members(count, members.includes(:roles))
    count
  end

  def exists?
    MemberCount.where(group: group, year: year).exists?
  end

  def mitgliederorganisation
    @mitgliederorganisation ||= group.mitgliederorganisation
  end

  def members
    Person.joins(:roles).
           where(roles: { group_id: group.self_and_descendants,
                          type: self.class.counted_roles.collect(&:sti_name),
                          deleted_at: nil }).
           uniq
  end

  private

  def new_member_count
    count = MemberCount.new
    count.group = group
    count.mitgliederorganisation = mitgliederorganisation
    count.year = year
    count
  end

  def count_members(count, people)
    people.each do |person|
      increment(count, count_field(person))
    end
  end

  def count_field(person)
    ROLE_MAPPING.each do |field, roles|
      if (person.roles.collect(&:class) & roles).present?
        return person.male? ? :"#{field}_m" : :"#{field}_f"
      end
    end
    nil
  end

  def increment(count, field)
    return unless field
    val = count.send(field)
    count.send("#{field}=", val ? val + 1 : 1)
  end

end
