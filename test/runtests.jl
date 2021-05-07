using Test
include("../src/thermo.jl")

@testset "Thermodynamic Functions" begin
    @test isapprox(temperature(290, 1004), 290)
    @test isapprox(temperature(290, 1004, celsius=true), 16.85)
    
    @test isapprox(pressure(1004), 1000)

    @test isapprox(wsat([270,290], [1000, 1004]), [0.0028296776778632955, 0.012165289848931712])

    @test isapprox(rh([0.002,0.002], [270,290], [1000, 1004]), [70.6794281075225, 16.4402165902823])

    @test isapprox(mslp(290, 950, 1000), 1009.07759)
end