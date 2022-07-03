include("../examples/sawtooth.jl")
using JLD
σ_o = 0.05
function generate_data(T, s)
	x = rand(T)
	y = rand(T)
	y[1] = (x[1] + σ_o*randn())%1
	for k = 1:(T-1)
		x[k+1] = next(x[k], s)
		y[k+1] = (x[k+1] + σ_o*randn())%1
	end
	return x, y
end
function log_likelihood(a)
		return log(1/sqrt(2π)/σ_o) -0.5*a*a/σ_o/σ_o
end
function cdf(x, xarr)
	N = size(xarr)[1]
	return 1/N*sum(xarr .<= x)
end
function posterior(xarr, y)
	N = size(xarr)[1]
	a_n = y .- xarr
	lklhd = log_likelihood.(a_n)
	prob = (1/N)*exp.(lklhd)
	prob ./= sum(prob)
	return prob
end
function opt_tran(c_pr, c_po, x)
	Tx = similar(x)
	for (k, cmf) in c_pr

	

	end
	return Tx
end
function transport_map(x_pr, post_pr)
	N = size(x_pr)[1]
	pr_pr = (1/N)*ones(N)
	cmf_pr = cumsum(pr_pr)
	cmf_post = cumsum(post_pr)
	return opt_tran(cmf_pr, cmf_post, x_pr)
end
function analysis(y, x)
	
end


function forecast(x, s, τ)
	for t = 1:τ
		x .= next.(x, s)
	end
	return x
end
function transport_filter(x,y,τ,T,N,s)
	x_pr = zeros(N,T)
	for t = 1:T
		x .= forecast(x, s, τ)
		x .= analysis(y[t], x)
		x_pr[:,t] .= x
    end
	return x_pr
end
function assimilate(N, Nthr, τ, T, s)
	x_t, y = generate_data(T, s)
	x = rand(N)
	x .= forecast(x, s, 1000)
	x_pr = transport_filter(x,y,τ,T,N,s)
	return x_pr, x_t, y 
end
