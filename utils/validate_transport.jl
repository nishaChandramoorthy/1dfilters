include("../src/filter.jl")
include("../src/transport_1D.jl")
include("../src/sir_1D.jl")
using PyPlot
function run_algs(T,s,N,τ,N_th)
	x_t, y = generate_data(T,s)
	x = rand(N)
	x .= forecast(x, s, 1000)
	sort!(x)
	
	w = ones(N)/N

	orbit = zeros(N,T)
	orbit_sir = zeros(N,T)
	w_orbit = zeros(N,T)
	x_sir = similar(x)
	x_sir .= x

	for t = 1:T
		x .= forecast(x, s, τ)
		x_sir .= forecast(x_sir, s, τ)

		x = transport_analysis(y[t],x)
		w .= analysis_sir(w, y[t], x_sir)

		N_eff = 1.0/sum(w.*w)
		if N_eff < N_th
			x_sir .= resample(x_sir, w)
		end
		
		orbit[:,t] .= x
		orbit_sir[:,t] .= x_sir
		w_orbit[:,t] .= w
	end
	return orbit, orbit_sir, w_orbit, x_t, y
end

function compare_fil_alg(T,s,N,τ,N_th)
	fig, ax = subplots(1,T)
	orbit, orbit_sir, w_orbit, true_orbit, obs = run_algs(T,s,N,τ,N_th)
	for t = 1:T
		ax[t].hist(orbit[:,t],density=true,bins=100,label="transport")
		ax[t].hist(orbit_sir[:,t],bins=100,weights=w_orbit[:,t],density=true,label="sir")

		ax[t].plot(obs[t],10.0,"^",ms=20,label="observation")
		ax[t].plot(true_orbit[t],10.0,"P",ms=20,label="true orbit")

		
		ax[t].xaxis.set_tick_params(labelsize=36)
		ax[t].yaxis.set_tick_params(labelsize=36)
		
		if t==1
			ax[t].legend(fontsize=25)
		end

	end
	return orbit, orbit_sir, w_orbit, true_orbit, obs
end


