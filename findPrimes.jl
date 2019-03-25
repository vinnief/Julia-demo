## prime number generation
##
if !@isdefined(primes) || primes==[] primes=[2,3] end
if !@isdefined(Divisors) end #(4 => [2])
   Divisors = Dict{Integer,Array{Integer}}()
if !@isdefined(DivisorsMult)  end #(12 =>[1,2,2,3,4,6,6,12]) or (12 => [2,2,3,4,6,6])
  DivisorsMult = Dict{Integer,Array{Integer}}()
if !@isdefined(PrimeDistinctDivisors) end #(4 => [2])
  PrimeDistinctDivisors=Dict{Integer,Array{Integer}}()
if !@isdefined(PrimeDivisors) end #(4 => [2,2])
   PrimeDivisors= Dict{Integer,Array{Integer}}()
function findFactor(n=4,nr=0,startindex=1,primes=primes,extendPrimes=true, debug=0)
    factors=BigInt[]
    if n==1 || startindex>length(primes)|| startindex<1 || !(typeof(n)<:Integer)return factors end
    if debug>=1 print(" factoring ",n,": ") end
    for p in primes[startindex:end]
        if n>=p && n%p==0
            push!(factors,p)
            if n!=p && nr!=1
                append!(factors,
                  findFactor(div(n,p),nr-1,indexin(p,primes)[1]))
            end
            return factors
        end
    end
    if extendPrimes
        while length(factors)==0
           p=addPrime!(1)
           if n%p==0
               push!(factors,p)
               if n!=p && nr!=1
                   append!(factors,
                      findFactor(div(n,p),nr-1,indexin(p,primes)[1]))
               end
               return factors
            end
        end
    end
    return factors
end

function findAFactor(n=60,primes=primes,debug=0)
  return findFactorsIn(n,1,1,false,primes,true,debug-1)
end
function findFactorsIn(n=60,nr=0,startindex=1, compositeFactors=false,potFactors=primes, extendPrimes=true,debug=0)
  factors = BigInt[]
  if n==1 || startindex>length(primes)|| startindex<1 return factors end
  if debug>=1 print(n," is being factored, ") end
  if debug>=4 && nr>0 print(" into ",nr," factors at most, ") end
  #if compositeFactors potFactors=collect(2:floor(BigInt,n/2)) end  #no need for this we can use it to find primes
  if debug>=3 print(" Checking ", primes[startindex:end]', " to begin with. ") end
  for p in potFactors[startindex:end]
    if p<=n && n%p==0
      if debug>=2 print(p, " is a divisor. ") end
      push!(factors,p)
      if nr==1 || n==p return factors end
      if !compositeFactors
        append!(factors,findFactorsIn(div(n,p), nr-1,indexin(p,potFactors)[1],compositeFactors,potFactors,extendPrimes,debug-1))
        return factors
      end
    end
  end  # if we reach this there was no prime divisor in potFactors, or compositeFactors=true
  #this means we have primes in potFactors,
  #and if extendprimes is true we need to get all needed primes to find more divisors.
  if extendPrimes
    startindex=length(potFactors)
    min=ceil(BigInt, sqrt(n))
    if potFactors[startindex]> min  return factors end #(push!(factors,n));  end
    if debug>0 print(" Extending with primes from highest known prime ", potFactors[startindex], " to at least ", min,". ") end
    addPrimesUntil!(min,1,debug-1,potFactors)
    append!(factors,findFactorsIn(n, nr,startindex,compositeFactors,potFactors,extendPrimes,debug-1))
  end
  return factors
end

function findNextPrime(primes=primes, method=1,debug=0, potPrime=primes[length(primes)]+2)
  if !isnothing(indexin(1,primes)[1]) throw("1 should not be in the potential divisor list") end
  if (method==1)
      while !isPrime(potPrime,method, debug-1, primes) potPrime+=2 end
  elseif method==2
        while length(findFactor(potPrime,1,1,primes,false,debug-1))>0 potPrime+=2 end #defaults: (n=4,nr=0,startindex=1,primes=primes,extendPrimes=true, debug=0)
  elseif method==3
      while findAFactor(potPrime,primes,debug-1)[1]!=potPrime potPrime+=2 end
  else
    throw("Method "*string(method)* " is unknown. Please choose a method from 1 to 3.")
  end
  if debug>0 print(" found prime: ", potPrime, " ") end
  return potPrime
end

function addPrime!(nr=1,method=1,primes=primes,debug=0)
    prime=primes[length(primes)]
    for k=1:nr
        prime=findNextPrime(primes, method, debug-1, prime+2)
        push!(primes,prime)
    end
    return prime
end

function addPrimesUntil!(n=4,method=1, debug=0,primes=primes)
  prime=primes[length(primes)]
  while prime<n
    prime=findNextPrime(primes, method, debug-1, prime+2)
    push!(primes,prime)
  end
  return prime
end
function isPrime(n=35,method=1,debug=0,primes=primes)
  if method==1 return isPrimeDirect(n,method,debug,primes)
  elseif method==2 return findFactor(n,1,1,primes,true,debug)##(n=4,nr=0,startindex=1,primes=primes,extendPrimes=true, debug=0)
  elseif method==3 return findAFactor(n,primes,debug)==[n]
  else throw(" method $method not Known, use 1,  2 or 3")
  end
end
# if you are sure primes contains all relevant primes, specify it.
# if afraid you might miss a factor, specify collect(2:floor(BigInt,n)), and loop over all integers
function isPrimeDirect(n=510511,method=1, debug=0, primes=primes)
    isprime=true
    for p in primes
      if n<=p break end
      if n%p==0
            isprime=false
            break
      end
    end
    if isprime
      lastp1=(primes[length(primes)]+1)
      if n<= lastp1*lastp1 return true
      else
        addPrimesUntil!(floor(BigInt,sqrt(n)),method,debug-1, primes)
        isprime=isPrimeDirect(n,method,debug,primes)
      end
    end
    return isprime
end
# thie is the end of the prime searching. now for the decompositions:

function findDistinctDivisors!(n,debug=0)
  res=get(Divisors,n,[])
  if res==[]  Divisors[n] = res = findFactorsIn(n,0,1,true,collect(2:n),false, debug-1) end
  return res
end

# this function is wrong, when there is need to expand the primes.
function findDistinctPrimeDivisors!(n,primes=primes,debug=0)
  if !@isdefined(PrimeDistinctDivisors) global PrimeDistinctDivisors= Dict{Integer,Array{Integer}}() end #(4 => [2]) end
  factors= get(PrimeDivisors,n,BigInt[] )
  if factors!=[] return factors
  else
    PrimeDistinctDivisors[n]=findFactorsIn(n,0,1,true,primes,true,debug-1)
  end
end

# next function is not needed any more?
function findPrimeDecomposition!(n=12,nr=0,start=1,primes=primes,debug=0)
  if !@isdefined(PrimeDivisors) global PrimeDivisors= Dict{Integer,Array{Integer}}()end #(4 => [2,2]) end
  factors= get(PrimeDivisors,n,BigInt[] )
  if n==1 || factors!=[] return factors end
  if !(typeof(n) <:Integer) return factors end
  println( " starting the loop in findprimedecomposition")
  for p in primes[start:end]
    if n>=p && n%p==0
      push!(factors,p)
      if nr!=1 && n!=p
        if debug>0 println("factorizing $n finding $nr factors ") end
        append!(factors,findPrimeDecomposition!(div(n,p), nr-1,indexin(p,primes)[1], primes,debug-1))
      end
      break
    end
  end
  if length(factors)==0 || (factors==[1]&&n!=1)
     endIndex= length(primes)
     if (primes[endIndex]+2)*(primes[endIndex]+2)<= n#
       AddPrime!(10,1,primes,debug-1)
       append!(factors,findPrimeDecomposition!(n,nr,endIndex+1,primes, debug-1))
     else push!(factors,n)  #throw("Error: No factors of $n found, largest factor checked is ",primes[length(primes)])
       return factors
     end
  end
  PrimeDivisors[n] = factors
  return factors
end
#next function is simply find prime decomposition using findFactorsIn
function findMultiplePrimeDivisors!(n,primes=primes,debug=0)
  if !@isdefined(PrimeDivisors) global PrimeDivisors= Dict{Integer,Array{Integer}}() end # (4 => [2,2]) end
  factors= get(PrimeDivisors,n,BigInt[] )
  if factors!=[] return factors end
  PrimeDivisors[n]=findFactorsIn(n,0,1,false,primes,true,debug-1)
end

function findDivisorswithMultiplicity!(n, primes=primes, debug=0)
  if !@isdefined(DivisorsMult) Divisors = Dict{Integer,Array{Integer}}() end
  result = get(DivisorsMult,n,[])
  if result!=[] return result end
  while primes[length(primes)]^2<n AddPrime!(2) end
  primedivs=findmultiplePrimeDivisors!(n, primes, debug-1)
  divisorswithMultiplicity = [1]
  for p in primedivs
    divisorswithMultiplicity = append!(divisorswithMultiplicity, divisorswithMultiplicity.*p)
  end
  DivisorsMult[n]= divisorswithMultiplicity
  return (divisorswithMultiplicity)
end

function sumDivisors(n,debug=0)
  if !@isdefined(DivisorSum) DivisorSum = Dict{Integer,Array{Integer}}() end
  res= get(DivisorSum,n,[])
  if res==[] DivisorSum[n] = res= 1+sum(findDistinctDivisors(n)) end
  return res
end

function isPerfect(n, debug=0)
  a= sumDivisors(n,debug-1)
  return sign(a-n)
end
function multiPerfect(n, debug=0)
  a= (sumDivisors(n,debug-1)+n)
   return a%n=0 ? a÷n : a
 end

function sumDivisorsMultiply(n,debug=0)
  if !@isdefined(DivisorsMultSum) DivisorSum = Dict{Integer,Array{Integer}}() end
  res= get(DivisorsMultSum,n,[])
  if res==[] DivisorsMultSum[n] = res= sum(makeDivisorswithMultiplicity(n))-n end
  return res
end

function isVeryPerfect(n, debug=0)
  a= sumDivisorsMultiply(n,debug-1)
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
  for k = 2:cyclelength a=sumDivisors(a,debug-1) end
  return n==sumDivisors(a,debug-1) ? a : 0
end
function moltoamico(n,cyclelength,debug=0)
  a=n
  for k=2:cyclelength a=sumDivisorsMultiply(a,debug-1) end
  return n==sumDivisorsMultiply(a,debug-1) ? a : 0
end
function multiPerfect(n, debug=0)
  sd= sumDivisors(n,debug-1)
  return (sd % n==0) ? (sd,n) : 0
end
## unittests
addPrimesUntil!(40,1)
addPrime!(1,3,primes,0)
primes'
for i=1:3
  print( "method ",i," ");@time(begin global primes=[2,3];addPrime!(5000, i, primes,0);primes' end)
end

# it seems isPrime is the best way of just searching for primes.
primes=BigInt[2,3]
@assert findFactorsIn(28,0,1, false,primes,false,0) ==[2,2]
@assert findFactorsIn(28,0,1, true,primes,false,0)==[2]
@assert findFactorsIn(28,0,1, false,primes,true,0)==[2,2,7] #does not extend primes, but does recognize "small" primes.
@assert primes==[2,3]
@assert findFactorsIn(28,0,1, true,primes,true,0) == [2,7]
@assert findAFactor(28,primes)== [2] #7 not in primes yet
@assert findMultiplePrimeDivisors!(28)==[2,2,7] #
@assert findDistinctPrimeDivisors!(28)==[2,7] #returns [2,2,7]
findDistinctPrimeDivisors!(2*2*3*11)# [2,3,11,11] wrong,
 # not meant to find 7 new primes, but finds some small prime anyway.
primes'
@assert findPrimeDecomposition!(28)==[2,2,7] # this function adds new primes
primes'

biggie=30*1001*17
@assert( findDistinctDivisors!(28,3) ==[2,4,7,14,28])
@assert
findDistinctPrimeFactors(2*2*3*7*7)
==[2,3,5,7]#
@assert findPrimeFactors!(17017,primes)==[7,11,13,17]  #adds 11,13,17 to primes
@assert findDistinctPrimeFactors(biggie^2)==[2,3,5,7,11,13,17]
@assert findmultiplePrimeFactors((biggie+1)^2)==BigInt[]  #19,19,19,97,97,97,277,277,277 not yet found
@assert findPrimeFactors!(biggie+1,primes)==[19,97,277]  #adds primes up to 277
@assert findmultiplePrimeFactors((biggie+1)^2)==BigInt[19,19,97,97,277,277] #found
## now do some timing
@time( for n=4:20 println(findFactor(n)) end)
@time( for n=4:20 println(findFactorsIn(n)) end)
@time( for n=4:20 println(findFactorsIn(n,0,1,true,primes)) end) # finds each factor exactly once!
@time( for n=4:20 println(findPrimeDecomposition!(n)) end)

@time(begin primes=[2,3];addPrime!(50,3);primes' end)

@time(findPrimeFactors!(biggie,primes,0))
@time(findDistinctPrimeFactors(biggie+1,primes))
@time(findDistinctDivisors(biggie+1))
@time(findDistinctDivisors(biggie+1))
print(findPrimeFactors!(biggie+1,primes))
print(primes')
@time(findPrimeDivisors!(biggie,0,1,false,primes,true,0))
@time(findFactorsIn(biggie,0,1,true,collect(2:biggie),false,0)) #note: use collect(2:biggie)
@time(findFactorsIn(biggie+1,0,1,true,collect(2:biggie),false,0))
@time(AddPrime!(24))
@time(AddPrime!(25))
@time(AddPrime!(25))
@time(AddPrime!(25))
@time(AddPrime!(200))
print(primes')
## test perfection
@assert isVeryPerfect(6)==0
@assert isPerfect(28)==0
@assert isPerfect(29,2)==-1




@time(begin n=100; print("Perfect numbers until ",n,": ");for i in 1:n isPerfect(i,3) end end)
# [1,6,28,496,8128]
@time(@assert begin n=1000; print("Perfect numbers until ",n,": ");
     [i for i in 1:n if isPerfect(i,0)==0]  end ==[1,6,28,496])
     # 0.141507 seconds (141.29 k allocations: 5.286 MiB)
primes=[2,3]
AddPrime!(100)
@assert makeDivisorswithMultiplicity(28)==[1,2,2,4,7,14,14,28]
for i in 2:10
  list= makeDivisorswithMultiplicity(i)
  println(length(list)," divisors of ",i,": ", list )
end
@time(@assert begin n=1000; print("very Perfect numbers until ",n,": ");[i for i in 1:n if isVeryPerfect(i,2)==0] end==[6])
#0.468230 seconds (226.86 k allocations: 77.772 MiB, 7.55% gc time)
@time(begin n=100; print("verysumdivisors numbers until ",n,": ");[ isVeryPerfect(i,0) for i in 1:n] end)
@time(  for i in 1:1001 if isVeryPerfect(i)==0 println(i, " is very perfect")end end)
# until 100001 was 145.212405 seconds (35.06 M allocations: 114.396 GiB, 11.57% gc time)
# only 6 is very perfect below 100001
@time( @assert [[n,amico(n)]  for n in 1:1001 if amico(n)!=0] ==[[1,1],[6,6],[28,28],[220,284],[284,220],[496,496]])
@time( @assert [[n,amico(n,3)]  for n in 1:1001 if amico(n,3)!=0]==[[1,1],[6,6],[28,28],[496,496]])
@time( @assert [[n,amico(n,4)]  for n in 1:1001 if amico(n,4)!=0]==[[1,1],[6,6],[28,28],[220,284],[284,220],[496,496]])
@time( [[n,amico(n,5)]  for n in 1:1001 if amico(n,5)!=0])==[1,1],[6,6],[28,28],[496,496]]
@time( [[n,amico(n,6)]  for n in 1:1001 if amico(n,6)!=0])==[[1,1],[6,6],[28,28],[220,284],[284,220],[496,496]]
@time( [[n,amico(n,7)]  for n in 1:1001 if amico(n,7)!=0])==[1,1],[6,6],[28,28],[496,496]]
@time( [[n,amico(n,8)]  for n in 1:1001 if amico(n,8)!=0])==[[1,1],[6,6],[28,28],[220,284],[284,220],[496,496]]

@time( [[n,moltoamico(n,1)]  for n in 1:1001 if moltoamico(n,1)!=0]) # 0.799494 seconds
@time( [[n,moltoamico(n,2)]  for n in 1:1001 if moltoamico(n,2)!=0]==[[6,6],[20,34],[34,20],[765,963],[963,765]]) #16.942204
@time( [[n,moltoamico(n,3)]  for n in 1:1001 if moltoamico(n,3)!=0])==[[6,6]]
# 338.246336 seconds (2.59 G allocations: 66.644 GiB, 28.81% gc time)

@time( [[n,moltoamico(n,4)]  for n in 1:101 if moltoamico(n,4)!=0]==[[6,6],[20,34],[34,20]]) #2.594176
@time( [[n,moltoamico(n,4)]  for n in 1:1000 if moltoamico(n,4)!=0]) # ==[[6,6],[20,34],[34,20]]) #2.594176

@time( [[n,moltoamico(n,5)]  for n in 1:101 if moltoamico(n,5)!=0]) #22.695123
@time( [[n,moltoamico(n,6)]  for n in 1:101 if moltoamico(n,6)!=0])
@time( [[n,moltoamico(n,7)]  for n in 1:101 if moltoamico(n,7)!=0])
@time( [[n,moltoamico(n,8)]  for n in 1:101 if moltoamico(n,8)!=0])




## plot some prime things
length(primes)

list= begin n=10000; [[i,isPerfect(i,0)] for i in 1:n] end
# or list= begin n=10000; [i,isVeryPerfect(i,0)] for i in 1:n] end
count( x[:,2].>0, list)

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
