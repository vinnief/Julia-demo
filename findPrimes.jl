## prime number generation
##
if !@isdefined(primes) || primes==[] end
primes=[2,3]
if !@isdefined(Divisors) end #(4 => [2])
Divisors = Dict{Integer,Array{Integer}}()
if !@isdefined(DivisorsMult)  end #(12 =>[1,2,2,3,4,6,6,12]) or (12 => [2,2,3,4,6,6])
DivisorsMult = Dict{Integer,Array{Integer}}()
if !@isdefined(PrimeDistinctDivisors) end #(4 => [2])
PrimeDistinctDivisors=Dict{Integer,Array{Integer}}()
if !@isdefined(PrimeDivisors) end #(4 => [2,2])
PrimeDivisors= Dict{Integer,Array{Integer}}()
if !@isdefined(DivisorSum) end
DivisorSum = Dict{Integer,Integer}()

#define generic factorization functions
function isPrime(n=35,method=1,debug=0,primes=primes)
  if method==1 return isPrimeDirect(n,method,debug=debug,primes=primes)
  elseif method==2 return findPrimeFactors!(n,1,1,primes,true,debug)##(n=4,nr=0,startindex=1,primes=primes,extendPrimes=true, debug=0)
  elseif method==3 return findOneFactorIn!(n,primes,debug)==[n]
  else throw(" method $method not Known, use 1,  2 or 3")
  end
end
function isPrimeDirect(n=510511,method=1; debug=0, primes=primes)
  isprime=true
  for p in primes
    if n<=p return true elseif n%p==0  return false end
  end
  if ExtendPrimes!(n;primes=primes,debug=debug-1)
    return isPrimeDirect(n,method,debug,primes)
  else  return isprime
  end
end

function extendPrimes!(n=60,method;primes=primes,debug=0)
  lastp2=(primes[length(primes)]+2)
  if n> lastp2*lastp2
    min=floor(BigInt, sqrt(n))
    if debug>0
      print(" Extending with primes from highest known prime ", primes[length(primesFactors)], " to at least ", min,". ")
    end
    addPrimesUntil!(min,method,debug-1, primes)
    return true
  else return false
  end
end

function factorUsing(n=41*43,nr=0,composite=false;primes=primes,debug=0)
  if !(typeof(n)<:Integer) throw(" $n not integer") end
  if debug>=1 print(" factoring $n:")
    if debug>=3
      if debug>=4 && nr>0 print(" into $nr factors at most. ") end
      print(" Checking ", primes', " ")
    end
  end
  if composite
    if !@isdefined(Divisors) global Divisors= Dict{Integer,Array{Integer}}()end #(4 => [2,2]) end
    DivList=Divisors
  else
    if !@isdefined(PrimeDivisors) global PrimeDivisors= Dict{Integer,Array{Integer}}()end #(4 => [2,2]) end
    DivList=PrimeDivisors
  end
  factors= get(DivList,n,BigInt[])
  if n==1 || factors!=[] return (1,0,factors) end
  originaln=n
  #print(primes , " the primes as in factorUsing ")
  for p in primes
      if n<p break end
      if n%p==0
          push!(factors,p)
          if debug>=2 print("$p,") end
          if !composite n = n ÷ p end
          nr=nr-1; if nr==0 break end
          if !composite
            (n,nr,factors2)=factorUsing(n,nr; primes=primes[indexin(p,primes)[1]:end],debug=debug) #primes not appended onto, so can subset
            append!(factors, factors2)
          end
      end
  end
  if n==1 || composite    DivList[originaln] = factors end
  return (n,nr,factors)
end
factorUsing(6)[3][1:2]
factorUsing(5)
function findFactorsIn!(n=60,nr=0,startindex=1, compositeFactors=false, extendPrimes=true;potFactors=primes,debug=0)
  originaln=n
  if debug>=2 print(" we will check factors ",potFactors[startindex:end], extendPrimes ? " and extend." : ". ") end
  n,nr,factors=factorUsing(n,nr,composite;primes=potFactors[startindex:end],debug=debug)
  if extendPrimes && n>1 && nr>0
    startindex=length(potFactors)+1
    if ExtendPrimes!(n,1;primes=potFactors)
      n,factors2=findFactorsIn!(n, nr,startindex,compositeFactors,potFactors,extendPrimes;debug=debug-1)
      append!(factors,factors2)
    else
      (push!(factors,n)) #we have a new prime! #(length(factors)==0) ???
      n=1  #  else throw(" no factors in $n but no extension of $primes was made!")   end
    end
  end
  if n==1
    if compositeFactors
      global Divisors[originaln] = factors end
    else
      global PrimeDivisors[originaln] = factors end
    end
    return n,factors
  else throw("while factoring $originaln there is $n left over, factors found: $factors" )
  end
end

function findOneFactorIn!(n=60;primes=primes,debug=0)
  return findFactorsIn!(n,1,1,false,true)[2][1]
end
findOneFactorIn!(6)
function findNextPrime(primes=primes, method=1; potPrime=primes[length(primes)]+2,debug=0)
  if !isnothing(indexin(1,primes)[1]) throw("1 should not be in the potential divisor list") end
  if debug>0 print( "primes: ") end
  if (method==1)
      while !isPrime(potPrime,method; debug=debug-1, primes=primes) potPrime+=2 end
  elseif method==2
        while length(findPrimeFactors!(potPrime,1,1,false;primes=primes,debug=debug-1))>0 potPrime+=2 end #defaults: (n=4,nr=0,startindex=1,primes=primes,extendPrimes=true, debug=0)
  elseif method==3
      while findOneFactorIn!(potPrime;primes=primes,debug=debug-1) !=potPrime potPrime+=2 end
  else
    throw("Method "*string(method)* " is unknown. Please choose a method from 1 to 3.")
  end
  if debug>0 print( potPrime, " ") end
  return potPrime
end

function addPrime!(nr=1,method=1;primes=primes,debug=0)
    prime=primes[length(primes)]
    for k=1:nr
        prime=findNextPrime(primes, method;debug= debug-1, potPrime=prime+2)
        push!(primes,prime)
        if debug>1 println(primes) end
    end
    return prime
end

function addPrimesUntil!(n=4,method=1; debug=0,primes=primes)
  prime=primes[length(primes)]
  while prime<n
    prime=findNextPrime(primes, method; debug=debug-1, potPrime=prime+2)
    push!(primes,prime)
  end
  return prime
end

# thie is the end of the prime searching. now for the decompositions:

function findDistinctDivisors!(n,debug=0)
  res=get(Divisors,n,[])
  if res==[]  Divisors[n] = res = findFactorsIn!(n,0,1,true,collect(2:n),false, debug-1) end
  return res
end

# this function is wrong, when there is need to expand the primes.
function findDistinctPrimeDivisors!(n,primes=primes,debug=0)
  if !@isdefined(PrimeDistinctDivisors) global PrimeDistinctDivisors= Dict{Integer,Array{Integer}}() end #(4 => [2]) end
  factors= get(PrimeDivisors,n,BigInt[] )
  if factors!=[] return factors
  else
    PrimeDistinctDivisors[n]=findFactorsIn!(n,0,1,true,primes,true,debug-1)
  end
end

#next function is simply find prime decomposition using findFactorsIn
function findMultiplePrimeDivisors!(n,primes=primes,debug=0)
  if !@isdefined(PrimeDivisors) global PrimeDivisors= Dict{Integer,Array{Integer}}() end # (4 => [2,2]) end
  factors= get(PrimeDivisors,n,BigInt[] )
  if factors!=[] return factors end
  PrimeDivisors[n]=findFactorsIn!(n,0,1,false,primes,true,debug-1)
end

function findDivisorswithMultiplicity!(n, primes=primes, debug=0)
  if !@isdefined(DivisorsMult) Divisors = Dict{Integer,Array{Integer}}() end
  result = get(DivisorsMult,n,[])
  if result!=[] return result end
  #while primes[length(primes)]^2<n addPrime!(2) end
  primedivs=findmultiplePrimeDivisors!(n, primes, debug-1)
  divisorswithMultiplicity = [1]
  for p in primedivs
    divisorswithMultiplicity = append!(divisorswithMultiplicity, divisorswithMultiplicity.*p)
  end
  DivisorsMult[n]= divisorswithMultiplicity
  return (divisorswithMultiplicity)
end

function sumDivisors(n,debug=0)
  if !@isdefined(DivisorSum) global DivisorSum = Dict{Integer,Integer}() end
  res= get(DivisorSum,n,[])
  if res==[]  DivisorSum[n] = res= 1+sum(findDistinctDivisors!(n)) end
  return res
end

function isPerfect(n, debug=0)
  return sumDivisors(n,debug-1)==n+n
end

function multiPerfect(n::BigInt, debug=0)
  if !@isdefined(RelDivSum) global RelDivSum = Dict{BigInt,Float64} end
  if !@isdefined(RelDivSumInt) global RelDivSum = Dict{BigInt,Integer} end
  res = get(RelDivSum,n,0)
  if res==0 RelDivSum[n]= (sum=sumDivisors)/n end
  resInt=get(RelDivSumInt,n,0)
  if resInt==0 && sum%n==0 RelDivSumInt=sum÷n end
  return sumDivisors(n,debug-1)%n==0
end

function sumDivisorsMultiply(n,debug=0)
  if !@isdefined(DivisorsMultSum) DivisorsMultSum = Dict{Integer,Integer}() end
  res= get(DivisorsMultSum,n,[])
  if res==[] DivisorsMultSum[n] = res= sum(findDivisorswithMultiplicity!(n)) end
  return res
end

function isVeryPerfect(n, debug=0)
  a= sumDivisorsMultiply(n,debug-1)
  if isodd(debug) print(n," ") end
  if  debug >= 2
    if a==n+n  print("perfect ")
    elseif a<n+n  print("thin ")
    elseif a>n+n print("fat ")
    end
  end
  return a==n+n
end

function amico(n,cyclelength=2, debug=0)
  a=n
  for k = 2:cyclelength a=sumDivisors(a,debug-1) end
  return n==sumDivisors(a,debug-1)-n ? a : 0
end
function moltoamico(n,cyclelength,debug=0)
  a=n
  for k=2:cyclelength a=sumDivisorsMultiply(a,debug-1)-n end
  return n==sumDivisorsMultiply(a,debug-1)-n ? a : 0
end
function multiPerfect(n, debug=0)
  return (sumDivisors(n,debug-1) % n==0)
end
## unittests
addPrimesUntil!(40,1)
addPrime!(1,1,primes,0)
addPrime!(1,2,primes,0)
addPrime!(1,3,primes,7)

for i=1:3
  print( "method ",i," ");@time(begin global primes=[2,3];addPrime!(5000, i, primes,0);primes' end)
end
primes1=[2,3]; primes2=[2,3]; primes3=[2,3]
addPrime!(5000, 1, primes1,0)
addPrime!(5000, 2, primes2,0)
addPrime!(5000, 3, primes3,0)
primes1==primes2
primes3==primes2

#===========================
method 1   1.024183 seconds (104.58 k allocations: 1006.703 MiB, 15.00% gc time)
method 2   1.265096 seconds (245.81 k allocations: 1.469 GiB, 18.77% gc time)
method 3   1.299971 seconds (386.22 k allocations: 1.471 GiB, 19.43% gc time)
it seemed in earlier versions isPrime was the best way of just searching for primes.:
not much less time but hugely less memory: some hundred MB instead of 1 GB
===========================#
primes=BigInt[2,3]
@assert findFactorsIn!(28,0,1, false,primes,false,0) ==[2,2]
@assert findFactorsIn!(28,0,1, true,primes,false,0)==[2]
@assert findFactorsIn!(28,0,1, false,primes,true,0)==[2,2,7]
#does not need to extend variable primes if n<=(largest prime+2)^2, so not here yet
@assert findFactorsIn!(25,0,1, false,primes,true,0)==[5,5] # nto extended yet
@assert findFactorsIn!(21,0,1, false,primes,true,0)==[3,7]
@assert findFactorsIn!(35,0,1, false,primes,true,0)==[5,7] # this added 5, not 7  !!
primes'
prod7=2*3*5*7*11*13*17
prod8=prod7*19
prod11=prod8*23*29*31

@time(findFactorsIn!(prod7,0,1,false,collect(2:prod7),false,0))
@time(findFactorsIn!(prod7,0,1,true,collect(2:prod7),false,0)) #note: use collect(2:prod7)
@time(findFactorsIn!(prod7,0,1,false,collect(2:prod7),false,0)) #note: use collect(2:prod7)
pots=collect(2:20)
@time(findFactorsIn!(41*43,0,1,false,collect(2:100),true,20))
findPrimeFactors!(prod7,0,1,collect(2:7),false)
findPrimeFactors!(big1,0,1,collect(2:7),false)
@time(findFactorsIn!(prod7+1,0,1,true,collect(2:(prod7+1)),false,0))

@assert primes==[2,3]
@assert findFactorsIn!(28,0,1, true,primes,true,0) == [2,7]
@assert findOneFactorIn!(28,primes)== [2] #7 not in primes yet
@assert findMultiplePrimeDivisors!(28)==[2,2,7] #
@assert findDistinctPrimeDivisors!(28)==[2,7] #returns [2,2,7]
findDistinctPrimeDivisors!(28)
findDistinctPrimeDivisors!(2*2*3*11)# [2,3,11] wrong,
# not meant to find 7 new primes, but finds some small prime anyway.
primes'
@assert findPrimeDecomposition!(28)==[2,2,7] # this function adds new primes
primes'
@assert( findDistinctDivisors!(28,3) ==[2,4,7,14,28])
@assert findDistinctPrimeDivisors!(2*2*3*7*7)==[2,3,7]#
#findDistinctPrimeDivisors!(2*2*3*7*7)
@assert findPrimeDecomposition!(17017,0,1,primes)==[7,11,13,17]  #adds 11,13,17 to primes
@assert findDistinctPrimeDivisors!(prod7^2)==[2,3,5,7,11,13,17]
@assert findmultiplePrimeFactors((prod7+1)^2)==BigInt[]  #19,19,19,97,97,97,277,277,277 not yet found
@assert findPrimeDecomposition!(prod7+1,primes)==[19,97,277]  #adds primes up to 277
@assert findmultiplePrimeFactors((prod7+1)^2)==BigInt[19,19,97,97,277,277] #found
## now do some timing
@time( for n=4:20 println(findPrimeFactors!(n)) end)
@time( for n=4:20 println(findFactorsIn!(n)) end)
@time( for n=4:20 println(findFactorsIn!(n,0,1,true,primes)) end) # finds each factor exactly once!
@time( for n=4:20 println(findPrimeDecomposition!(n)) end)

@time(begin primes=[2,3];addPrime!(50,3);primes' end)

@time(findPrimeDecomposition!(prod7,primes,0))
@time(findDistinctPrimeFactors(prod7+1,primes))
@time(findDistinctDivisors!(prod7+1))
@time(findDistinctDivisors!(prod7+1))
print(findPrimeDecomposition!(prod7+1,primes))
findPrimeFactors!(prod7+1,primes)
print(primes')
@time(findPrimeDivisors!(prod7,0,1,false,primes,true,0))
@time(addPrime!(24))
@time(addPrime!(25))
@time(addPrime!(25))
@time(addPrime!(25))
@time(addPrime!(200))
print(primes')
##test Dict making
@assert sumDivisors(28)==28+28
Divisors
@assert(isPerfect(28))
@time([i for i = 1:500 if isPerfect(i)])
Divisors
DivisorSum
multiPerfect(28)

## test perfection
@assert isVeryPerfect(6)
@assert !isPerfect(29,2)




@time(begin n=100; print("Perfect numbers until ",n,": ");for i in 1:n isPerfect(i,3) end end)
# [1,6,28,496,8128]
@time(@assert begin n=1000; print("Perfect numbers until ",n,": ");
     [i for i in 1:n if isPerfect(i,0)==0]  end ==[1,6,28,496])
     # 0.141507 seconds (141.29 k allocations: 5.286 MiB)
primes=[2,3]
addPrime!(100)
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
