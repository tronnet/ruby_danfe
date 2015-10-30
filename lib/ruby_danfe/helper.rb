module RubyDanfe
  class Helper
    def self.numerify(number, decimals = 2)
      return "" if !number || number == ""
      number = number.gsub(",", ".")

      numbers = number.split(".")
      if numbers.count > 2
        number = ""
        numbers.each_with_index do |n, index|
          if index == numbers.size - 1
            number += ".#{n}"
          else
            number += n
          end
        end
      end
      int, frac = ("%.#{decimals}f" % number).split(".")
      int.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1\.")
      int + "," + frac
    end

    def self.invert(y)
      28.7.cm - y
    end

    def self.remove_white_spaces(info)
      info.gsub(/\p{Space}/, '')
    end

    def self.get_emit_date(xml)
      dh_emi = ""
      if !xml['ide/dEmi'].blank?
        dh_emi = xml['ide/dEmi']
      elsif !xml['ide/dhEmi'].blank?
        dh_emi = xml.css('dhEmi').text
        dh_emi = Date.parse(dh_emi).strftime('%Y-%m-%d')
      end
      return self.date_parser(dh_emi)
    end

    def self.get_out_date(xml)
      dh_out = ""
      if !xml['ide/dSaiEnt'].blank?
        dh_out = xml['ide/dSaiEnt']
      elsif !xml['ide/dhSaiEnt'].blank?
        dh_out = xml.css('dhSaiEnt').text
        dh_out = Date.parse(dh_out).strftime('%Y-%m-%d')
      end
      return self.date_parser(dh_out)
    end

    def self.date_parser(info)
      return "" if info.blank?
      tt = info.split('-')
      return "#{tt[2]}/#{tt[1]}/#{tt[0]}"
    end

    def self.get_out_hour(xml)
      dh_out = ""
      if !xml['ide/dSaiEnt'].blank?
        dh_out = xml['ide/dSaiEnt']
        dh_out = Date.parse(dh_out).strftime('%d/%m/%Y')
      elsif !xml['ide/dhSaiEnt'].blank?
        dh_out = xml.css('dhSaiEnt').text
        dh_out = Time.parse(dh_out).strftime("%H:%M:%S")
      end
      return dh_out
    end

    def self.as_cnpj_cpf(str)
      return "%s.%s.%s/%s-%s" %[str[0..1], str[2..4], str[5..7], str[8..11], str[12..13]] if str.length == 14
      return "%s.%s.%s-%s" %[str[0..2], str[3..5], str[6..8], str[9..10]] if str.length == 11
      return ""
    end

    def self.as_cep(str)
      return "%s.%s-%s" %[str[0..1], str[2..4], str[5..7]]
    end

    def self.as_phone_number(str)
      case str.length
      when 8
        return "%s-%s" %[str[0..3], str[4..7]]
      when 10
        return "(%s)%s-%s" %[str[0..1], str[2..5], str[6..9]]
      when 11
        if str[0] == "0"
          return "(%s)%s-%s" %[str[0..2], str[3..6], str[7..10]] if str.length == 11
        else
          return "(%s)%s-%s" %[str[0..1], str[2..6], str[7..10]] if str.length == 11
        end
      else
        return str
      end
    end

    def self.split_semicolon(str)
      info = str.split(';')
      resp = "";
      for x in 0...info.count()
        resp += "#{info[x]}\n"
      end
      return resp
    end
  end
end
