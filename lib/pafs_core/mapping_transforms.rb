# frozen_string_literal: true

module PafsCore
  module MappingTransforms
    NGR_CODES = [
      %w[HL HM HN HO HP JL JM JN],
      %w[HQ HR HS HT HU JQ JR JS],
      %w[HV HW HX HY HZ JV JW JX],
      %w[NA NB NC ND NE OA OB OC],
      %w[NF NG NH NJ NK OF OG OH],
      %w[NL NM NN NO NP OL OM ON],
      %w[NQ NR NS NT NU OQ OR OS],
      %w[NV NW NX NY NZ OV OW OX],
      %w[SA SB SC SD SE TA TB TC],
      %w[SF SG SH SJ SK TF TG TH],
      %w[SL SM SN SO SP TL TM TN],
      %w[SQ SR SS ST SU TQ TR TS],
      %w[SV SW SX SY SZ TV TW TX]
    ].reverse.freeze

    def code_map
      @code_map ||= build_code_map
    end

    def build_code_map
      map = {}
      NGR_CODES.each_with_index do |r, north|
        r.each_with_index do |c, east|
          map[c] = [east, north]
        end
      end
      map
    end

    # Get OS Grid ref part (2 letters at the start)
    def get_os_grid_ref(grid_ref)
      code_map.fetch(grid_ref[0..1], nil) unless grid_ref.nil?
    end

    # Converts OS National Grid Reference to easting/northing
    # grid_ref should be upper case and not contain spaces
    def grid_reference_to_eastings_and_northings(grid_ref)
      gr = get_os_grid_ref(grid_ref)
      return if gr.nil?

      n = grid_ref[2..]
      hl = n.length / 2
      {
        easting: "#{gr[0]}#{n[0..(hl - 1)]}".ljust(6, "0").to_i,
        northing: "#{gr[1]}#{n[hl..]}".ljust(6, "0").to_i
      }
    end

    # Converts easting/northing coords into WGS84 latitude/longitude
    def easting_northing_to_latitude_longitude(easting, northing)
      osgb36 = easting_northing_to_osgb36(easting, northing)
      osgb36_to_wgs84(osgb36[:latitude], osgb36[:longitude])
    end

    # rubocop:disable Layout/SpaceAroundOperators, Layout/ExtraSpacing
    # Converts easting/northing coords into OSGB36 latitude/longitude
    def easting_northing_to_osgb36(easting, northing)
      osbg_f0   = 0.9996012717
      n0        = -100_000.0
      e0        = 400_000.0
      phi0      = deg_to_rad(49.0)
      lambda0   = deg_to_rad(-2.0)
      a         = 6_377_563.396
      b         = 6_356_256.909
      e_squared = ((a * a) - (b * b)) / (a * a)
      est       = easting
      nrth      = northing
      n         = (a - b) / (a + b)
      m         = 0.0
      phi_prime = ((nrth - n0) / (a * osbg_f0)) + phi0

      loop do
        m = (b * osbg_f0) \
          * (((1 + n + ((5.0 / 4.0) * n * n) + ((5.0 / 4.0) * n * n * n)) \
              * (phi_prime - phi0)) \
          - (((3 * n) + (3 * n * n) + ((21.0 / 8.0) * n * n * n)) \
             * Math.sin(phi_prime - phi0) \
             * Math.cos(phi_prime + phi0)) \
          + ((((15.0 / 8.0) * n * n) + ((15.0 / 8.0) * n * n * n)) \
             * Math.sin(2.0 * (phi_prime - phi0)) \
             * Math.cos(2.0 * (phi_prime + phi0))) \
          - (((35.0 / 24.0) * n * n * n) \
             * Math.sin(3.0 * (phi_prime - phi0)) \
             * Math.cos(3.0 * (phi_prime + phi0))))

        phi_prime += (nrth - n0 - m) / (a * osbg_f0)
        break unless (nrth - n0 - m) >= 0.001
      end

      v   = a * osbg_f0 * ((1.0 - (e_squared * sin_pow_2(phi_prime))) ** -0.5)
      rho = a * osbg_f0 * (1.0 - e_squared) * ((1.0 - (e_squared * sin_pow_2(phi_prime))) ** -1.5)

      eta_squared = (v / rho) - 1.0

      vii = Math.tan(phi_prime) / (2 * rho * v)

      viii = (Math.tan(phi_prime) / (24.0 * rho * (v ** 3.0))) *
             (5.0 + (3.0 * tan_pow_2(phi_prime)) + eta_squared -
             (9.0 * tan_pow_2(phi_prime) * eta_squared))

      ix = (Math.tan(phi_prime) / (720.0 * rho * (v ** 5.0))) *
           (61.0 + (90.0 * tan_pow_2(phi_prime)) + (45.0 * tan_pow_2(phi_prime) *
           tan_pow_2(phi_prime)))

      x = sec(phi_prime) / v

      xi = (sec(phi_prime) / (6.0 * v * v * v)) *
           ((v / rho) + (2 * tan_pow_2(phi_prime)))

      xii = (sec(phi_prime) / (120.0 * (v ** 5.0))) *
            (5.0 + (28.0 * tan_pow_2(phi_prime)) + (24.0 * tan_pow_2(phi_prime) *
            tan_pow_2(phi_prime)))

      xiia = (sec(phi_prime) / (5040.0 * (v ** 7.0))) *
             (61.0 + (662.0 * tan_pow_2(phi_prime)) +
             (1320.0 * tan_pow_2(phi_prime) * tan_pow_2(phi_prime)) +
             (720.0 * tan_pow_2(phi_prime) * tan_pow_2(phi_prime) *
             tan_pow_2(phi_prime)))

      phi = phi_prime - (vii * ((est - e0) ** 2.0)) +
            (viii * ((est - e0) ** 4.0)) - (ix * ((est - e0) ** 6.0))

      lmbda = lambda0 + (x * (est - e0)) - (xi * ((est - e0) ** 3.0)) +
              (xii * ((est - e0) ** 5.0)) - (xiia * ((est - e0) ** 7.0))

      { latitude: rad_to_deg(phi), longitude: rad_to_deg(lmbda) }
    end

    # Convert OSGB36 latitude/longitude coords
    # into WGS84 latitude/longitude
    def osgb36_to_wgs84(latitude, longitude)
      a         = 6_377_563.396
      b         = 6_356_256.909
      e_squared = ((a * a) - (b * b)) / (a * a)

      phi = deg_to_rad(latitude)
      lmbda = deg_to_rad(longitude)
      v = a / Math.sqrt(1 - (e_squared * sin_pow_2(phi)))
      h = 0
      x = (v + h) * Math.cos(phi) * Math.cos(lmbda)
      y = (v + h) * Math.cos(phi) * Math.sin(lmbda)
      z = (((1 - e_squared) * v) + h) * Math.sin(phi)

      tx =        446.448
      ty =       -124.157
      tz =        542.060

      s  =         -0.0000204894
      rx = deg_to_rad(0.00004172222)
      ry = deg_to_rad(0.00006861111)
      rz = deg_to_rad(0.00023391666)

      xb = tx + (x * (1 + s)) + (-rx * y)     + (ry * z)
      yb = ty + (rz * x)      + (y * (1 + s)) + (-rx * z)
      zb = tz + (-ry * x)     + (rx * y)      + (z * (1 + s))

      a         = 6_378_137.000
      b         = 6_356_752.3141
      e_squared = ((a * a) - (b * b)) / (a * a)

      lambda_b = rad_to_deg(Math.atan(yb / xb))
      p_dist = Math.sqrt((xb * xb) + (yb * yb))
      phi_n = Math.atan(zb / (p_dist * (1 - e_squared)))

      (1..10).each do |_i|
        v = a / Math.sqrt(1 - (e_squared * sin_pow_2(phi_n)))
        phi_n1 = Math.atan((zb + (e_squared * v * Math.sin(phi_n))) / p_dist)
        phi_n = phi_n1
      end

      phi_b = rad_to_deg(phi_n)

      { latitude: phi_b.round(6), longitude: lambda_b.round(6) }
    end
    # rubocop:enable Layout/SpaceAroundOperators, Layout/ExtraSpacing

    private # Some math helpers

    def deg_to_rad(degrees)
      degrees / 180.0 * Math::PI
    end

    def rad_to_deg(rad)
      (rad / Math::PI) * 180
    end

    def sin_pow_2(angle)
      Math.sin(angle) * Math.sin(angle)
    end

    def cos_pow_2(angle)
      Math.cos(angle) * Math.cos(angle)
    end

    def tan_pow_2(angle)
      Math.tan(angle) * Math.tan(angle)
    end

    def sec(angle)
      1.0 / Math.cos(angle)
    end
  end
end
