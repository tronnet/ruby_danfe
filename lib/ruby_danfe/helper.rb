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
  end
end
