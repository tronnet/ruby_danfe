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

    def self.get_emit_date(xml)
      dh_emi = ""
      if !xml['ide/dEmi'].blank?
        dh_emi = xml['ide/dEmi']
      elsif !xml['ide/dhEmi'].blank?
        dh_emi = xml.css('dhEmi').text
        dh_emi = Date.parse(dh_emi).strftime('%Y-%m-%d')
      end
      return dh_emi
    end

    def self.get_out_date(xml)
      dh_out = ""
      if !xml['ide/dSaiEnt'].blank?
        dh_out = xml['ide/dSaiEnt']
      elsif !xml['ide/dhSaiEnt'].blank?
        dh_out = xml.css('dhSaiEnt').text
        dh_out = Date.parse(dh_out).strftime('%Y-%m-%d')
      end
      return dh_out
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
  end
end
