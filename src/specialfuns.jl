module SpecialFuncs

using PyCall
using SymPy
using SpecialFunctions



# Still in base
import Base: gamma, lgamma
gamma(x::Sym, args...; kwargs...) = sympy_meth(:gamma, x, args...; kwargs...)
lgamma(x::Sym, args...; kwargs...) = sympy_meth(:loggamma, x, args...; kwargs...)



                        
## https://github.com/JuliaMath/SpecialFunctions.jl/blob/master/src/SpecialFunctions.jl
## julia -> sympy mapping.
julia_sympy_map = (
                   :airyai       => :airyai,
                   :airyaiprime  => :airyaiprime,
                   :airybi       => :airybi,
                   :airybiprime  => :airybiprime,
                   :airyaix      => :nothing,
                   :airyaiprimex => :nothing,
                   :airybix      => :nothing,
                   :airybiprimex => :nothing,
                   :besselh      => :nothing,
                   :besselhx     => :nothing,
##                   :besseli      => :besseli,
                   :besselix     => :nothing,
##                   :besselj      => :besselj,
                   :besselj0     => :nothing,
:besselj1   => :nothing,
:besseljx   => :nothing,
## :besselk    => :besselk,
:besselkx   => :nothing,
## :bessely    => :bessely,
:bessely0   => :nothing,
:bessely1   => :nothing,
:besselyx   => :nothing,
:dawson     => :nothing,
:erf        => :erf,
:erfc       => :erfc,
:erfcinv    => :erfcinv,
:erfcx      => :nothing,
:erfi       => :erfi,
:erfinv     => :erfinv,
:eta        => :nothing,
:digamma    => :digamma,
:invdigamma => :nothing,
:polygamma  => :polygamma,
:trigamma   => :trigamma,
:hankelh1   => :nothing,
:hankelh1x  => :nothing,
:hankelh2   => :nothing,
:hankelh2x  => :nothing,
:zeta       => :zeta,
#
#  SymPy only
#
:nothing    => :uppergamma,
:nothing    => :lowergamma,
:nothing    => :erf2,
:nothing    => :erfcx,
:nothing    => :erf2inv,
:nothing    => :fresnels,
:nothing    => :fresnelc,
:nothing    => :Ei,
:nothing    => :expint,
:nothing    => :li,
:nothing    => :Li,
:nothing    => :Si,
:nothing    => :Ci,
:nothing    => :Shi,
:nothing    => :Chi,
:nothing    => :hankel1,
:nothing    => :hankel2,
:nothing    => :jn,
:nothing    => :yn,
:nothing    => :hn1,
:nothing    => :hn2,
:nothing    => :jn_zeros,
:nothing    => :dirichlet_eta,
:nothing    => :polylog,
:nothing    => :lerchphi,
:nothing    => :stieltjes,
:nothing    => :elliptic_k,
:nothing    => :elliptic_f,
:nothing    => :elliptic_e,
:nothing    => :elliptic_pi,
:nothing    => :mathieus,
:nothing    => :mathieuc,
:nothing    => :mathieusprime,
:nothing    => :mathieucprime,
:nothing    => :jacobi,
:nothing    => :jacobi_normalized,
:nothing    => :gegenbauer,
:nothing    => :chebyshevt,
:nothing    => :chebyshevu,
:nothing    => :chebyshevt_root,
:nothing    => :chebyshevu_root,
:nothing    => :legendre,
:nothing    => :assoc_legendre,
:nothing    => :hermite,
:nothing    => :laguerre,
:nothing    => :assoc_laguerre,
:nothing    => :Ynm,
:nothing    => :Ynm_c

)

                      
for (jmeth, smeth) in [(j,s) for (j,s) in julia_sympy_map if s !== :nothing && j!== :nothing]
    meth_name = string(smeth)
    eval(Expr(:import, :SpecialFunctions, jmeth))
    @eval begin
        @doc """
        `$($meth_name)`: a SymPy function.
            The SymPy documentation can be found through: http://docs.sympy.org/latest/search.html?q=$($meth_name)
            """ ->
        ($jmeth)(x::Sym, xs...;kwargs...) = sympy_meth($meth_name, x, xs...; kwargs...)
        
    end
end


## only in SymPy
for meth in [v for (k,v) in julia_sympy_map if k == :nothing]
    meth_name = string(meth)
    @eval begin
        @doc """
            `$($meth_name)`: a SymPy function.
                The SymPy documentation can be found through: http://docs.sympy.org/latest/search.html?q=$($meth_name)
                """ ->
        ($meth)(xs...; kwargs...) = sympy_meth($meth_name, xs...; kwargs...)
    end
    eval(Expr(:export, meth))
end



## these have (parameter, x) signature. Use symbolic x to call sympy version, othewise
## should dispatch to julia version.
for fn in (:besselj, :bessely, :besseli, :besselk)
    meth = string(fn)
    eval(Expr(:import, :SpecialFunctions, fn))
    @eval ($fn)(nu::Number, x::Sym; kwargs...) = sympy_meth($meth, nu, x; kwargs...)
    @eval ($fn)(nu::Number, a::AbstractArray{Sym}) = map(x ->$fn(nu, x), a)
end





## Hyper and friends don't really have symbolic use...
"""

Evaluates the generalized hypergeometric function:
[hyper](http://docs.sympy.org/dev/modules/mpmath/functions/hypergeometric.html#hyper)

"""
hyper(as::Vector{T}, bs::Vector{S}, z::Number) where {T<:Number, S<:Number} = sympy_meth(:hyper, as, bs, z)
export hyper

"""

[docs](http://docs.sympy.org/dev/modules/mpmath/functions/hypergeometric.html#meijer-g-function)

"""
function meijerg(a1s::Vector{T}, a2s::Vector{T}, b1s::Vector{S}, b2s::Vector{S}, z::Number, r=1;kwargs...) where {T<:Number, S<:Number}
    sympy_meth(:meijerg, a1s, a2s, b1s, b2s, z;  kwargs...)
end
export meijerg

end
