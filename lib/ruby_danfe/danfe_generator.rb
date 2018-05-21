# coding: utf-8
module RubyDanfe
  class DanfeGenerator
    def initialize(xml)
      @xml = xml
      @pdf = Document.new
      @vol = 0
    end

    def freight_mode(f_type)
      case f_type
        when "0" then '0 - Emitente'
        when "1" then '1 - Destinatário'
        when "2" then '2 - Terceiros'
        when "3" then '3 - Transporte próprio por conta do Remetente'
        when "9" then '9 - Sem frete'
      end
    end

    def generatePDF
      @pdf.repeat :all do
        render_canhoto
        render_emitente
        render_titulo
        render_faturas
        render_calculo_do_imposto
        render_transportadora_e_volumes
        render_cabecalho_dos_produtos
        render_calculo_do_issqn
        render_dados_adicionais
      end

      render_produtos

      @pdf.page_count.times do |i|
        @pdf.go_to_page(i + 1)
        @pdf.ibox 1.00, 3.08, 7.71, 5.54, '',
        "FOLHA #{i + 1} de #{@pdf.page_count}", {:size => 8, :align => :center, :valign => :center, :border => 0, :style => :bold}
      end

      @pdf
    end

    private
    def render_canhoto
      receb = "EMISSÃO: #{Helper.date_parser(@xml['ide/dhEmi'][0..9])} VALOR TOTAL: R$ #{@xml['total/ICMSTot/vProd']} DESTINATÁRIO: #{@xml['dest/xNome']} - #{@xml['dest/enderDest/xLgr']}, #{@xml['dest/enderDest/nro']} #{@xml['dest/enderDest/xBairro']} #{@xml['dest/enderDest/xMun']}-#{@xml['dest/enderDest/UF']}"
      @pdf.ibox 0.85, 16.10, 0.25, 0.42, "RECEBEMOS DE #{@xml['emit/xNome']} OS PRODUTOS CONSTANTES DA NOTA FISCAL INDICADA ABAIXO:", receb, {:size => 6}
      @pdf.ibox 0.85, 4.10, 0.25, 1.27, "DATA DE RECEBIMENTO"
      @pdf.ibox 0.85, 12.00, 4.35, 1.27, "IDENTIFICAÇÃO E ASSINATURA DO RECEBEDOR"

      @pdf.ibox 1.70, 4.50, 16.35, 0.42, '',
        "NF-e\n" +
        "N°. " + @xml['ide/nNF'] + "\n" +
        "SÉRIE " + @xml['ide/serie'], {:align => :center, :valign => :center}
    end

    def render_emitente
      @pdf.ibox 3.92, 7.46, 0.25, 2.54, '',
        @xml['emit/xNome'] + "\n" +
        @xml['enderEmit/xLgr'] + ", " + @xml['enderEmit/nro'] + "\n" +
        @xml['enderEmit/xBairro'] + " - " + @xml['enderEmit/CEP'] + "\n" +
        @xml['enderEmit/xMun'] + "/" + @xml['enderEmit/UF'] + "\n" +
        @xml['enderEmit/fone'] + " " + @xml['enderEmit/email'], {:size => 9, :align => :center, :valign => :center}

      @pdf.ibox 3.92, 3.08, 7.71, 2.54

      @pdf.ibox 0.60, 3.08, 7.71, 2.54, '', "DANFE", {:size => 12, :align => :center, :border => 0, :style => :bold}
      @pdf.ibox 1.20, 3.08, 7.71, 3.14, '', "DOCUMENTO AUXILIAR DA NOTA FISCAL ELETRÔNICA", {:size => 8, :align => :center, :border => 0}
      @pdf.ibox 0.60, 3.08, 7.71, 4.34, '', "#{@xml['ide/tpNF']} - " + (@xml['ide/tpNF'] == '0' ? 'ENTRADA' : 'SAÍDA'), {:size => 8, :align => :center, :border => 0}

      @pdf.ibox 1.00, 3.08, 7.71, 4.94, '',
        "N°. " + @xml['ide/nNF'] + "\n" +
        "SÉRIE " + @xml['ide/serie'], {:size => 8, :align => :center, :valign => :center, :border => 0, :style => :bold}

      @pdf.ibox 2.20, 10.02, 10.79, 2.54
      @pdf.ibarcode 1.50, 8.00, 10.9010, 4.44, @xml['chNFe']
      @pdf.ibox 0.85, 10.02, 10.79, 4.74, "CHAVE DE ACESSO", @xml['chNFe'].gsub(/(\d)(?=(\d\d\d\d)+(?!\d))/, "\\1 "), {:style => :bold, :align => :center}
      @pdf.ibox 0.85, 10.02, 10.79, 5.60 , '', 'Consulta de autenticidade no portal nacional da NF-e' + "\n" 'www.nfe.fazenda.gov.br/portal ou no site da Sefaz Autorizadora', {:align => :center, :size => 8}
      @pdf.ibox 0.85, 10.54, 0.25, 6.46, "NATUREZA DA OPERAÇÃO", @xml['ide/natOp'], {:style => :bold}
      @pdf.ibox 0.85, 10.02, 10.79, 6.46, "PROTOCOLO DE AUTORIZAÇÃO DE USO", "#{@xml['infProt/nProt']} - #{@xml['infProt/dhRecbto']}", {:style => :bold, :align => :center}

      @pdf.ibox 0.85, 6.86, 0.25, 7.31, "INSCRIÇÃO ESTADUAL", @xml['emit/IE'], {:style => :bold}
      @pdf.ibox 0.85, 6.86, 7.11, 7.31, "INSC.ESTADUAL DO SUBST. TRIBUTÁRIO", @xml['emit/IEST'], {:style => :bold}
      @pdf.ibox 0.85, 6.84, 13.97, 7.31, "CNPJ", Helper.as_cnpj_cpf(@xml['emit/CNPJ']), {:style => :bold}
    end

    def render_titulo
      @pdf.ititle 0.42, 10.00, 0.25, 8.16, "DESTINATÁRIO / REMETENTE"

      @pdf.ibox 0.85, 12.32, 0.25, 8.58, "NOME/RAZÃO SOCIAL", @xml['dest/xNome'], {:style => :bold}
      @pdf.ibox 0.85, 5.33, 12.57, 8.58, "CNPJ/CPF", Helper.as_cnpj_cpf(@xml['dest/CNPJ']), {:style => :bold} if @xml['dest/CNPJ'] != ''
      @pdf.ibox 0.85, 5.33, 12.57, 8.58, "CNPJ/CPF", Helper.as_cnpj_cpf(@xml['dest/CPF']), {:style => :bold} if @xml['dest/CPF'] != ''
      @pdf.ibox 0.85, 2.92, 17.90, 8.58, "DATA DA EMISSÃO", Helper.get_emit_date(@xml), {:style => :bold, :align => :right}
      @pdf.ibox 0.85, 10.16, 0.25, 9.43, "ENDEREÇO", "#{@xml['enderDest/xLgr']}, #{@xml['enderDest/nro']}", {:style => :bold}
      @pdf.ibox 0.85, 4.83, 10.41, 9.43, "BAIRRO", @xml['enderDest/xBairro'], {:style => :bold}
      @pdf.ibox 0.85, 2.67, 15.24, 9.43, "CEP", Helper.as_cep(@xml['enderDest/CEP']), {:style => :bold}
      @pdf.ibox 0.85, 2.92, 17.90, 9.43, "DATA DA SAÍDA/ENTRADA", Helper.get_out_date(@xml), {:style => :bold, :align => :right}
      @pdf.ibox 0.85, 7.11, 0.25, 10.28, "MUNICÍPIO", @xml['enderDest/xMun'], {:style => :bold}
      @pdf.ibox 0.85, 4.06, 7.36, 10.28, "FONE/FAX", Helper.as_phone_number(@xml['enderDest/fone']), {:style => :bold}
      @pdf.ibox 0.85, 1.14, 11.42, 10.28, "UF", @xml['enderDest/UF'], {:style => :bold}
      @pdf.ibox 0.85, 5.33, 12.56, 10.28, "INSCRIÇÃO ESTADUAL", @xml['dest/IE'], {:style => :bold}
      @pdf.ibox 0.85, 2.92, 17.90, 10.28, "HORA DE SAÍDA", Helper.get_out_hour(@xml), {:style => :bold, :align => :right}
    end

    def render_faturas
      @pdf.ititle 0.42, 10.00, 0.25, 11.12, "FATURA / DUPLICATAS"
      @pdf.ibox 0.85, 20.57, 0.25, 11.51

      x = 0.25
      y = 11.51

      @xml.collect('xmlns', 'fat') do |det|
        @pdf.ibox 0.85, 2.12, x, y, '', 'Núm. Fatura:', { :size => 7, :border => 0, :style => :italic }
        @pdf.ibox 0.85, 2.12, x + 1.60, y, '', det.css('nFat').text, { :size => 7, :border => 0, :style => :bold }
        @pdf.ibox 0.85, 2.12, x, y + 0.20, '', 'Valor Orig.:', { :size => 7, :border => 0, :style => :italic }
        @pdf.ibox 0.85, 2.12, x + 1.60, y + 0.20, '', ('R$ ' + Helper.numerify(det.css('vOrig').text)), { :size => 7, :border => 0, :style => :bold }
        @pdf.ibox 0.85, 2.12, x, y + 0.40, '', 'Valor Liq.: ', { :size => 7, :border => 0, :style => :italic }
        @pdf.ibox 0.85, 2.12, x + 1.60, y + 0.40, '', ('R$ ' + Helper.numerify(det.css('vLiq').text)), { :size => 7, :border => 0, :style => :bold }
        x = x + 3.20
      end

      @xml.collect('xmlns', 'dup') do |det|
        @pdf.ibox 0.85, 2.12, x, y, '', 'Núm. Dup.:', { :size => 7, :border => 0, :style => :italic }
        @pdf.ibox 0.85, 2.12, x + 1.30, y, '', det.css('nDup').text, { :size => 7, :border => 0, :style => :bold }
        @pdf.ibox 0.85, 2.12, x, y + 0.20, '', 'Vencimento:', { :size => 7, :border => 0, :style => :italic }
        dtduplicata = det.css('dVenc').text
        dtduplicata = dtduplicata.present? ? dtduplicata[8,2] + '/' + dtduplicata[5, 2] + '/' + dtduplicata[0, 4] : ""
        @pdf.ibox 0.85, 2.12, x + 1.30, y + 0.20, '', dtduplicata, { :size => 7, :border => 0, :style => :bold }
        @pdf.ibox 0.85, 2.12, x, y + 0.40, '', 'Valor:', { :size => 7, :border => 0, :style => :italic }
        @pdf.ibox 0.85, 2.12, x + 1.30, y + 0.40, '', ('R$ ' + Helper.numerify(det.css('vDup').text)), { :size => 7, :border => 0, :style => :bold }
        x = x + 2.80
      end
    end

    def render_calculo_do_imposto
      @pdf.ititle 0.42, 5.60, 0.25, 12.36, "CÁLCULO DO IMPOSTO"

      @pdf.inumeric 0.85, 4.06, 0.25, 12.78, "BASE DE CÁLCULO DO ICMS", @xml['ICMSTot/vBC'], {:style => :bold}
      @pdf.inumeric 0.85, 4.06, 4.31, 12.78, "VALOR DO ICMS", @xml['ICMSTot/vICMS'], {:style => :bold}
      @pdf.inumeric 0.85, 4.06, 8.37, 12.78, "BASE DE CÁLCULO DO ICMS ST", @xml['ICMSTot/vBCST'], {:style => :bold}
      @pdf.inumeric 0.85, 4.06, 12.43, 12.78, "VALOR DO ICMS ST", @xml['ICMSTot/vST'], {:style => :bold}
      @pdf.inumeric 0.85, 4.32, 16.49, 12.78, "VALOR TOTAL DOS PRODUTOS", @xml['ICMSTot/vProd'], {:style => :bold}
      @pdf.inumeric 0.85, 3.46, 0.25, 13.63, "VALOR DO FRETE", @xml['ICMSTot/vFrete'], {:style => :bold}
      @pdf.inumeric 0.85, 3.46, 3.71, 13.63, "VALOR DO SEGURO", @xml['ICMSTot/vSeg'], {:style => :bold}
      @pdf.inumeric 0.85, 3.46, 7.17, 13.63, "DESCONTO", @xml['ICMSTot/vDesc'], {:style => :bold}
      @pdf.inumeric 0.85, 3.46, 10.63, 13.63, "OUTRAS DESPESAS ACESSORIAS", @xml['ICMSTot/vOutro'], {:style => :bold}
      @pdf.inumeric 0.85, 3.46, 14.09, 13.63, "VALOR DO IPI", @xml['ICMSTot/vIPI'], {:style => :bold}
      @pdf.inumeric 0.85, 3.27, 17.55, 13.63, "VALOR TOTAL DA NOTA", @xml['ICMSTot/vNF'], {:style => :bold}
    end

    def render_transportadora_e_volumes
      @pdf.ititle 0.42, 10.00, 0.25, 14.48, "TRANSPORTADOR / VOLUMES TRANSPORTADOS"

      @pdf.ibox 0.85, 9.02, 0.25, 14.90, "RAZÃO SOCIAL", @xml['transporta/xNome'], {:style => :bold}
      @pdf.ibox 0.85, 2.79, 9.27, 14.90, "FRETE POR CONTA", freight_mode(Helper.remove_white_spaces(@xml['transp/modFrete'])), {:style => :bold}
      @pdf.ibox 0.85, 1.78, 12.06, 14.90, "CODIGO ANTT", @xml['veicTransp/RNTC'], {:style => :bold}
      @pdf.ibox 0.85, 2.29, 13.84, 14.90, "PLACA DO VEÍCULO", @xml['veicTransp/placa'], {:style => :bold}
      @pdf.ibox 0.85, 0.76, 16.13, 14.90, "UF", @xml['veicTransp/UF'], {:style => :bold}
      @pdf.ibox 0.85, 3.94, 16.89, 14.90, "CNPJ/CPF", Helper.as_cnpj_cpf(@xml['transporta/CNPJ']), {:style => :bold}
      @pdf.ibox 0.85, 9.02, 0.25, 15.75, "ENDEREÇO", @xml['transporta/xEnder'], {:style => :bold}
      @pdf.ibox 0.85, 6.86, 9.27, 15.75, "MUNICÍPIO", @xml['transporta/xMun'], {:style => :bold}
      @pdf.ibox 0.85, 0.76, 16.13, 15.75, "UF", @xml['transporta/UF'], {:style => :bold}
      @pdf.ibox 0.85, 3.94, 16.89, 15.75, "INSCRIÇÂO ESTADUAL", @xml['transporta/IE'], {:style => :bold}

      @vol = 0
      @xml.collect('xmlns', 'vol') do |det|
        @vol += 1
        if @vol < 2
          @pdf.ibox 0.85, 2.92, 0.25, 16.60, "QUANTIDADE", det.css('qVol').text, {:style => :bold}
          @pdf.ibox 0.85, 3.05, 3.17, 16.60, "ESPÉCIE", det.css('esp').text, {:style => :bold}
          @pdf.ibox 0.85, 3.05, 6.22, 16.60, "MARCA", det.css('marca').text, {:style => :bold}
          @pdf.ibox 0.85, 4.83, 9.27, 16.60, "NUMERAÇÃO", det.css('nVol').text, {:style => :bold}
          @pdf.inumeric 0.85, 3.43, 14.10, 16.60, "PESO BRUTO", det.css('pesoB').text, {:decimals => 3, :style => :bold}
          @pdf.inumeric 0.85, 3.30, 17.53, 16.60, "PESO LÍQUIDO", det.css('pesoL').text, {:decimals => 3, :style => :bold}
        else
          break
        end
      end
    end

    def render_cabecalho_dos_produtos
      @pdf.ititle 0.42, 10.00, 0.25, 17.45, "DADOS DO PRODUTO / SERVIÇO"

      @pdf.ibox 6.70, 1.50, 0.25, 17.87, "CÓDIGO"
      @pdf.ibox 6.70, 4.80, 1.75, 17.87, "DESCRIÇÃO"
      @pdf.ibox 6.70, 1.00, 6.55, 17.87, "NCM"
      @pdf.ibox 6.70, 0.80, 7.55, 17.87, "CST"
      @pdf.ibox 6.70, 1.00, 8.35, 17.87, "CEST"
      @pdf.ibox 6.70, 1.00, 9.35, 17.87, "CFOP"
      @pdf.ibox 6.70, 1.00, 10.35, 17.87, "UNID"
      @pdf.ibox 6.70, 1.30, 11.35, 17.87, "QUANT"
      @pdf.ibox 6.70, 1.50, 12.65, 17.87, "VALOR UNIT"
      @pdf.ibox 6.70, 1.50, 14.15, 17.87, "VALOR TOT"
      @pdf.ibox 6.70, 1.50, 15.65, 17.87, "BASE CÁLC"
      @pdf.ibox 6.70, 1.00, 17.15, 17.87, "VL ICMS"
      @pdf.ibox 6.70, 1.00, 18.15, 17.87, "VL IPI"
      @pdf.ibox 6.70, 0.90, 19.15, 17.87, "% ICMS"
      @pdf.ibox 6.70, 0.86, 20.05, 17.87, "% IPI"

      @pdf.horizontal_line 0.25.cm, 20.83.cm, :at => Helper.invert(18.17.cm)
    end

    def render_calculo_do_issqn
      @pdf.ititle 0.42, 10.00, 0.25, 24.64, "CÁLCULO DO ISSQN"

      @pdf.ibox 0.85, 5.08, 0.25, 25.06, "INSCRIÇÃO MUNICIPAL", @xml['emit/IM'], {:style => :bold}
      @pdf.ibox 0.85, 5.08, 5.33, 25.06, "VALOR TOTAL DOS SERVIÇOS", @xml['total/vServ'], {:style => :bold}
      @pdf.ibox 0.85, 5.08, 10.41, 25.06, "BASE DE CÁLCULO DO ISSQN", @xml['total/vBCISS'], {:style => :bold}
      @pdf.ibox 0.85, 5.28, 15.49, 25.06, "VALOR DO ISSQN", @xml['total/ISSTot'], {:style => :bold}
    end

    def render_dados_adicionais
      @pdf.ititle 0.42, 10.00, 0.25, 25.91, "DADOS ADICIONAIS"

      if @vol > 1
        @pdf.ibox 3.07, 12.93, 0.25, 26.33, "INFORMAÇÕES COMPLEMENTARES", '', {:size => 8, :valign => :top}
        @pdf.ibox 3.07, 12.93, 0.25, 26.60, '', 'CONTINUAÇÃO TRANSPORTADOR/VOLUMES TRANSPORTADOS', {:size => 5, :valign => :top, :border => 0}
        v = 0
        y = 26.67
        @xml.collect('xmlns', 'vol') do |det|
          v += 1
          if v > 1
            @pdf.ibox 0.35, 0.70, 0.25, y + 0.10, '', 'QUANT.:', { :size => 4, :border => 0 }
            @pdf.ibox 0.35, 0.70, 0.90, y + 0.10, '', det.css('qVol').text, { :size => 4, :border => 0, :style => :italic }
            @pdf.ibox 0.35, 0.50, 1.35, y + 0.10, '', 'ESP.:', { :size => 4, :border => 0 }
            @pdf.ibox 0.35, 3.00, 1.75, y + 0.10, '', det.css('esp').text, { :size => 4, :border => 0, :style => :italic }
            @pdf.ibox 0.35, 0.70, 4.15, y + 0.10, '', 'MARCA:', { :size => 4, :border => 0 }
            @pdf.ibox 0.35, 2.00, 4.75, y + 0.10, '', det.css('marca').text, { :size => 4, :border => 0, :style => :italic }
            @pdf.ibox 0.35, 1.00, 6.10, y + 0.10, '', 'NUM.:',  { :size => 4, :border => 0 }
            @pdf.ibox 0.35, 1.30, 7.00, y + 0.10, '', 'PESO B.:', { :size => 4, :border => 0 }
            @pdf.inumeric 0.35, 1.30, 7.00, y + 0.10, '', det.css('pesoB').text, {:decimals => 3, :size => 4, :border => 0, :style => :italic }
            @pdf.ibox 0.35, 0.90, 8.50, y + 0.10, '', 'PESO LÍQ.:', { :size => 4, :border => 0 }
            @pdf.inumeric 0.35, 1.50, 8.50, y + 0.10, '', det.css('pesoL').text, {:decimals => 3, :size => 4, :border => 0, :style => :italic }
            y = y + 0.15
          end
        end
        @pdf.ibox 2.07, 12.93, 0.25, y + 0.30, '', 'OUTRAS INFORMAÇÕES', {:size => 6, :valign => :top, :border => 0}
        @pdf.ibox 2.07, 12.93, 0.25, y + 0.50, '', Helper.split_semicolon(@xml['infAdic/infCpl']), {:size => 5, :valign => :top, :border => 0}
      else
        info_comp = "#{@xml['infAdic/infCpl']};#{@xml['infAdFisco']}"
        @pdf.ibox 3.07, 12.93, 0.25, 26.33, "INFORMAÇÕES COMPLEMENTARES", Helper.split_semicolon(info_comp), {:size => 6, :valign => :top}
      end

      @pdf.ibox 3.07, 7.62, 13.17, 26.33, "RESERVADO AO FISCO"
    end

    def render_produtos
      @pdf.font_size(6) do
        @pdf.itable 6.37, 21.50, 0.25, 18.17,
          @xml.collect('xmlns', 'det') { |det|
            if !det.css('prod/nFCI').text.empty?
              descricao = <<-string
              #{det.css('prod/xProd').text}

              FCI: #{det.css('prod/nFCI').text}
              string
            else
              descricao = "#{det.css('prod/xProd').text}\n#{det.css('infAdProd').text}"
            end

            [
              det.css('prod/cProd').text, #I02
              descricao, #I04
              det.css('prod/NCM').text, #I05
              Cst.to_danfe(det), #N11
              det.css('prod/CEST').text,
              det.css('prod/CFOP').text, #I08
              det.css('prod/uCom').text, #I09
              Helper.numerify(det.css('prod/qCom').text), #I10
              Helper.numerify(det.css('prod/vUnCom').text), #I10a
              Helper.numerify(det.css('prod/vProd').text), #I11
              Helper.numerify(det.css('ICMS/*/vBC').text), #N15
              Helper.numerify(det.css('ICMS/*/vICMS').text), #N17
              Helper.numerify(det.css('IPI/*/vIPI').text), #O14
              Helper.numerify(det.css('ICMS/*/pICMS').text), #N16
              Helper.numerify(det.css('IPI/*/pIPI').text) #O13
            ]
          },
          :column_widths => {
            0 => 1.50.cm,
            1 => 4.80.cm,
            2 => 1.00.cm,
            3 => 0.80.cm,
            4 => 1.00.cm,
            5 => 1.00.cm,
            6 => 1.00.cm,
            7 => 1.30.cm,
            8 => 1.50.cm,
            9 => 1.50.cm,
            10 => 1.50.cm,
            11 => 1.00.cm,
            12 => 1.00.cm,
            13 => 0.90.cm,
            14 => 0.86.cm
          },
          :cell_style => {:padding => 2, :border_width => 0} do |table|
            @pdf.dash(5);
            table.column(6..14).style(:align => :right)
            table.column(0..14).border_width = 1
            table.column(0..14).borders = [:bottom]
          end
      end
    end
  end
end
