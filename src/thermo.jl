const cp = 1004.0
const R = 287.0
const p0 = 1000.0

"""
    temperature(theta, exner; celsius=false)
Returns temperature given potential temperature (`THETA` in RAMS) 
and the exner function * c_p (`PI` in RAMS). Specify `celsius=true` for celsius.
"""
function temperature(theta, exner; celsius=false)
    T = theta .* exner ./ cp

    if celsius
        T = T .- 273.15
    end

    return T
end

"""
    pressure(exner)
Return the pressure given the Exner function (`PI` in RAMS).
"""
function pressure(exner)
    p = p0 .* (exner ./ cp).^(cp/R)
    return p
end

"""
    wsat(theta, exner)
Saturation mixing ratio based on `THETA` and exner (`PI`). 

Note: for this function `THETA` and `PI` must be arrays
"""
function wsat(theta, exner)
    T = temperature(theta, exner; celsius=true)
    p = pressure(exner)

    c0 = 0.6105851e3
    c1 = 0.4440316e2
    c2 = 0.1430341e1
    c3 = 0.2641412e-1
    c4 = 0.2995057e-3
    c5 = 0.2031998e-5
    c6 = 0.6936113e-8
    c7 = 0.2564861e-11
    c8 = -0.3704404e-13

    T[T .< -80] .= -80
    x = T
    es = c0.+x.*(c1.+x.*(c2.+x.*(c3.+x.*(c4.+x.*(c5.+x.*(c6.+x.*(c7.+x.*c8)))))))

    ws = 0.622 .* es ./ (p.*100 .- es)
    return ws
end

"""
    rh(rv, theta, exner)
Calculates RH in percent (divide by 100 for fraction)
Note: for this function `THETA` and `PI` must be arrays
"""
function rh(rv, theta, exner)
    ws = wsat(theta, exner)
    rh = (rv ./ ws) .* 100.0

    return rh

end

"""
    mslp(temp, press, height)
Calculate Mean Sea Level Pressure from temperature, pressure, and height
"""
function mslp(temp, press, height)
    slp = press .* (1 .- (0.0065 .* height)./(temp .+ 0.0065 .* height .+ 273.15)).^-5.257
    return slp
end
