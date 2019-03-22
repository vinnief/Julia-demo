## prime number generation
##function findFactorsIn(n=BigInt(2),potFactors=BigInt[2,3],nr=0,startindex=1, compositeFactors=true, debug=0)
function findFactorsIn(n=(2),potFactors=[2,3],nr=0,startindex=1, compositeFactors=true, debug=0)
  factors = BigInt[]
  if n==1 return factors end
  for p in potFactors[startindex:end]
   if n%p==0
     if debug>2 print(p, " ") end
     push!(factors,p)
     if nr==1 return factors end
     if !compositeFactors
        append!(factors,findFactorsIn(div(n,p), potFactors, nr-1,indexin(p,primes)[1],false, debug))
        return factors
      end
    end
   end
  return factors
end
function findDistinctDivisors(n,debug=0)
  return findFactorsIn(n,2:(n-1),0,1,true, debug)
end

function findAFactor(n=2,primes=[2,3])
  return findFactorsIn(n,primes,1,1,false)
end

function findPrimeFactors!(n=2,primes=[2,3],nr=0)
  factors = BigInt[]
  for p in primes
    if n%p==0
      push!(factors,p)
      if nr!=1 && n!=p
        #println("factorizing $n finding $nr factors ")
        append!(factors,findPrimeFactors!(div(n,p), primes, nr-1))
      end
      break
    end
  end
  if length(factors)==0
     if primes[length(primes)]< n
       AppendNPrimes!(1,primes)
       append!(factors,findPrimeFactors!(n,primes,nr))
     else println("No factors found, largest factor checked is ",primes[length(primes)])
       return factors
     end
  end
  return factors
end

function findNextPrime(primes=[2,3])
  n=primes[length(primes)]
  while length(findAFactor(n,primes))>0 n+=2 end
  return n
end

function AppendNPrimes!(nr,primes)
  for i=1:nr push!(primes, findNextPrime(primes)) end
  return primes
end

function findDistinctPrimeFactors(n,primes=primes,debug=0)
  findFactorsIn(n,primes,0,1,true,debug)
end

function findmultiplePrimeFactors(n,primes=primes,debug=0)
  findFactorsIn(n,primes,0,1,false,debug)
end
function makeDivisorswithMultiplicity(n, primes=primes, debug=0)
  if isnothing(primes) && primes==[] primes=[2,3] end
  while primes[length(primes)]<n AppendNPrimes!(3,primes) end
  primedivs=findmultiplePrimeFactors(n, primes, debug)
  divisorswithMultiplicity = [1]
  for p in primedivs
    divisorswithMultiplicity = append!(divisorswithMultiplicity, divisorswithMultiplicity.*p)
  end
  return (divisorswithMultiplicity)
end

## unittests
@assert(findDistinctDivisors((28),3)==[2,4,7,14])
primes=BigInt[2,3]
@assert findFactorsIn(28,primes,0,1, false,3)==[2,2] #7 not in primes yet
@assert findPrimeFactors!(28,primes)==[2,2,7] # this function adds new primes
@assert findFactorsIn(28,primes,0,1, false,3)==[2,2,7]
@assert findFactorsIn(28,primes,0,1, true,3)==[2,7]
@assert findAFactor(28,primes)== [2]
biggie=30*1001*17
@assert findDistinctPrimeFactors(510510^2)==[2,3,5,7]#
@assert findPrimeFactors!(17017,primes)==[7,11,13,17]  #adds 11,13,17 to primes
@assert findDistinctPrimeFactors(biggie^2)==[2,3,5,7,11,13,17]
@assert findmultiplePrimeFactors((biggie+1)^2)==BigInt[]  #19,19,19,97,97,97,277,277,277 not yet found
@assert findPrimeFactors!(biggie+1,primes)==[19,97,277]  #adds primes up to 277
@assert findmultiplePrimeFactors((biggie+1)^2)==BigInt[19,19,97,97,277,277] #found

#### now do some timing

@time(findPrimeFactors!(biggie,primes,0))
@time(findDistinctPrimeFactors(biggie+1,primes))
@time(findDistinctDivisors(biggie+1))
@time(findDistinctDivisors(biggie+1))
print(findPrimeFactors!(biggie+1,primes))
print(primes')
@time(findPrimeFactors!(biggie,primes,0))
@time(findFactorsIn(biggie,2:biggie,0))
@time(findFactorsIn(biggie+1,2:biggie,0))
@time(AppendNPrimes!(24,primes))
@time(AppendNPrimes!(25,primes))
@time(AppendNPrimes!(25,primes))
@time(AppendNPrimes!(25,primes))
@time( AppendNPrimes!(200,primes))
print(primes[1:50]')
print(primes')

##
function sumDivisors(n,debug=0)
  return 1+sum(findDistinctDivisors(n))
end
function isPerfect(n, debug=3)
  a= sumDivisors(n,debug)
  if isodd(debug) print(n," ") end
  if  debug >= 2
    if a==n  print("perfect ")
    elseif a<n  print("thin ")
    elseif a>n print("fat ")
    end
  end
  return sign(a-n)
end
function sumDivisorsMultiply(n,debug=0)
  return sum(makeDivisorswithMultiplicity(n))-n
end
function isFatPerfect(n, debug=0)
  a= sumDivisorsMultiply(n,debug)
  if isodd(debug) print(n," ") end
  if  debug >= 2
    if a==n  print("perfect ")
    elseif a<n  print("thin ")
    elseif a>n print("fat ")
    end
  end
  return sign(a-n)
end
function amico(n,cyclelength=2, debug=0)
  a=n
  for k = 1:cyclelength a=sumDivisors(a,debug) end
  return n==sumDivisors(a) ? a : 0
end
## test perfection

isPerfect(28,2)
isPerfect(29,2)
@time(begin n=100; print("Perfect numbers until ",n,": ");for i in 1:n isPerfect(i,2) end end)
primes=[2,3]
AppendNPrimes!(100,primes)
makeDivisorswithMultiplicity(28)==[1,2,2,4,7,14,14,28]
for i in 2:10
  list= makeDivisorswithMultiplicity(i)
  println(length(list)," divisors of ",i,": ", list )
end
@time(begin n=100; print("Perfect numbers until ",n,": ");for i in 1:n isFatPerfect(i,2) end end)

@time(begin n=100; print("Fat Perfect numbers until ",n,": ");[ isFatPerfect(i,2) for i in 1:n] end)
@time(  for i in 1:1001 if isFatPerfect(i)==0 println(i, " is Fat perfect")end end)
# until 100001 was 145.212405 seconds (35.06 M allocations: 114.396 GiB, 11.57% gc time)
# only 6 is fatperfect below 100001
@time(  for n in 1:1001 a=amico(n);if a!==0  println(n, " has as friend ", a)end end)
@time(  for n in 1:10001 a=amico(n,3);if a!==0  println(n, " has as 2nd friend ", a)end end)
@time(  for n in 1:1001 a=amico(n,4);if a!==0  println(n, " has as 3nd friend ", a)end end)


## plot some prime things
length(primes)

list= begin n=10000; [isPerfect(i,0) for i in 1:n] end
list= begin n=10000; [isFatPerfect(i,0) for i in 1:n] end
count( x-> x>0, list)
count(x-> x<0, list)
count(x-> x==0, list)
using Plots; gr()
histogram(list,nbins=3)
pie(count( x-> x>0, list),)
count(x-> x<0, list),
count(x-> x==0, list))
function histmod(primes,n)
  histogram(primes.%n,nbins=n)
end
for n=1:div(length(primes),100)
  histmod(primes,primes[n])
  sleep(4)
end
histmod(primes,primes[16])
plot(map(x->x^2-10x, -10:18))
