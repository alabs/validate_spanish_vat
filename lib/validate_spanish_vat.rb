require "validate_spanish_vat/version"

module ValidateSpanishVat

  def self.validate(value)
    case
      when value.match(/[0-9]{8}[a-z]/i)
        return validate_nif(value)
      when value.match(/[a-wyz][0-9]{7}[0-9a-z]/i)
        return validate_cif(value)
      when value.match(/[x][0-9]{7,8}[a-z]/i)
        return validate_nie(value)
    end
    return false
  end

  def self.validate_nif(value)
    letters = "TRWAGMYFPDXBNJZSQVHLCKE"
    check = value.slice!(value.length - 1..value.length - 1).upcase
    calculated_letter = letters[value.to_i % 23].chr

    return check === calculated_letter
  end

  def self.validate_cif(value)
    letter = value.slice!(0).chr.upcase
    check = value.slice!(value.length - 1).chr.upcase

    n1 = n2 = 0
    for idx in 0..value.length - 1
      number = value.slice!(0).chr.to_i
      if (idx % 2) != 0
        n1 += number
      else
        n2 += ((2*number) % 10) + ((2 * number) / 10)
      end
    end
    calculated_number = (10 - ((n1 + n2) % 10)) % 10
    calculated_letter = (64 + calculated_number).chr

    if letter.match(/[QPNS]/)
      return check.to_s == calculated_letter.to_s
    else
      return check.to_i == calculated_number.to_i
    end
  end

  def self.validate_nie(value)
    value[0] = '0'
    value.slice(0) if value.size > 9
    validate_nif(value)
  end
end
