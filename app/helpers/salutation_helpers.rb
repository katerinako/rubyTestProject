module SalutationHelpers
  def dear_salutation(person)
    sex = (person.respond_to?(:sex) ? person.sex : 'N') || 'N'
    I18n.t "dear_salutation.#{sex}", :name => person.last_name, :salutation => salutation(person) 
  end 

  def salutation(person)
    sex = (person.respond_to?(:sex) ? person.sex.upcase : 'N') || 'N'
    name = person.respond_to?(:last_name) ? person.last_name : person.to_s
    title = person.respond_to?(:title) ? normalized_title(person.title) : nil

    scopes = [:salutation, title].reject(&:nil?)

    I18n.t sex, :scope => scopes
  end

  def normalized_title(title)
    case title
    when /prof\..*dr\./i
      :prof
    when /(dr|pract)\..**med\./i
      :dr
    else
      nil
    end
  end
  private :normalized_title

end