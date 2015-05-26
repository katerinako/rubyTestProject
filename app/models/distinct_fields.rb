module DistinctFields

  def distinct_values_for(field, term, limit)
    scoped.select("distinct #{field}").
           where(field.matches => term).
           order(field).
           limit(limit).
           map(&field)
  end
end
