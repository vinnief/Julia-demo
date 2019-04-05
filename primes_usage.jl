## plot some prime things
import Pkg

path = pwd()
push!(LOAD_PATH, chomp(path))
Pkg.add(name="663291fe-5589-11e9-3852-37f861a59017")
#"findPrimes.jl")
using findPrimes

include("findPrimes.jl")
length(primes)
list= begin n=10000; [i for i in 1:n if isPerfect(i)] end
# or list= begin n=10000; [i,isVeryPerfect(i,0)] for i in 1:n] end

@time count([ sumDivisors(i)>4i for i in 1:100000])
using Plots; gr()
histogram([sumDivisors(i)-i for i in 2:110000]),nbins=10)
pie(count( [sumDivisors(i)>3i for i in 2:100000]),)
count([sumDivisors(i)<3i for i in 2:100000])
count([sumDivisors(i)==2i for i in 2:110000])
function histmod(primes,n)
  histogram(primes.%n,nbins=n)
end
for n=1:div(length(primes),100)
  histmod(primes,primes[n])
  sleep(4)
end
histmod(primes,primes[16])
plot(map(x->x^2-10x, -10:18))
histogram(repeat(Divisors!(510510)[1:end-1],inner=10,outer=2), nbins=2)
histogram(primes)
plot([(i,primes[i]/i) for i in keys(primes)])
dp=diff(primes)
plot([(i,dp[i]) for i in keys(dp)])

addPrimesUntil!(100000) # returns the number of primes added to reach largest prime below this.
primes[end]

clingCycle=Dict{Integer,Array{Integer}}()
countClingy(2)
countClingy(3)
countClingy(4)
countClingy(5)
countClingy(6)
countClingy(7)
countClingy(8)
countClingy(9)
countClingy(10)
countClingy(220)
clingCycle
res=for i in 2:2000 countClingy(i,upperlevel=100) end
sumDivisors(3)-3
