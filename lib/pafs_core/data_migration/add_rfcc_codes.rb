# frozen_string_literal: true

module PafsCore
  module DataMigration
    class AddRfccCodes
      class << self
        def up
          # map PSO areas to RFCC codes
          pso_rfcc_map = {
            "PSO Berkshire and Buckinghamshire" => "TH",
            "PSO Cambridge and Bedfordshire" => "AC",
            "PSO Cheshire and Merseyside" => "NW",
            "PSO Coastal Essex Suffolk and Norfolk" => "AE",
            "PSO Coastal Lincolnshire and Northamptonshire" => "AN",
            "PSO Cumbria" => "NW",
            "PSO Derbyshire and Leicestershire" => "TR",
            "PSO Dorset and Wiltshire" => "WX",
            "PSO Durham and Tees Valley" => "NO",
            "PSO East Devon and Cornwall" => "SW",
            "PSO East Kent" => "SO",
            "PSO East Sussex" => "SO",
            "PSO East Yorkshire" => "YO",
            "PSO Essex" => "AE",
            "PSO Greater Manchester" => "NW",
            "PSO Hampshire and Isle of Wight" => "SO",
            "PSO Herefordshire and Gloucestershire" => "SN",
            "PSO Lancashire" => "NW",
            "PSO Lincolnshire" => "AN",
            "PSO London East" => "TH",
            "PSO London West" => "TH",
            "PSO Luton Hertfordshire and Essex" => "TH",
            "PSO Norfolk and Suffolk" => "AE",
            "PSO North Yorkshire" => "YO",
            "PSO Nottinghamshire and Tidal Trent" => "TR",
            "PSO Oxfordshire" => "TH",
            "PSO Shropshire Worcestershire Telford and Wrekin" => "SN",
            "PSO Somerset" => "WX",
            "PSO South East London and North Kent" => "TH",
            "PSO South West London and Mole" => "TH",
            "PSO South Yorkshire" => "YO",
            "PSO Staffordshire and the Black Country" => "TR",
            "PSO Surrey" => "TH",
            "PSO Test Area" => "TS",
            "PSO Tyne and Wear and Northumberland" => "NO",
            "PSO Warwickshire Birmingham Solihull and Coventry" => "SN",
            "PSO Welland and Nene" => "AN",
            "PSO West Devon and Cornwall" => "SW",
            "PSO West Kent" => "SO",
            "PSO West of England" => "WX",
            "PSO West Sussex" => "SO",
            "PSO West Yorkshire" => "YO"
          }

          pso_rfcc_map.each do |pso_name, code|
            pso = PafsCore::Area.find_by(area_type: PafsCore::Area::PSO_AREA, name: pso_name)
            next if pso.nil?

            pso.update(sub_type: code)
          end
        end

        def down
          PafsCore::Area.where(area_type: PafsCore::Area::PSO_AREA).update(sub_type: nil)
        end
      end
    end
  end
end
