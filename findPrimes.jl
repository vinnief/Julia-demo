## prime number generation and factorization
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
if !@isdefined(DivisorSum) end
DivisorSum = Dict{Integer,Integer}()

#define generic factorization functions
function isPrime(n=510511; debug=0, primes=primes)
  if n%2==0 return false end
  for p in primes[2:end]
    if n%p==0 return false
    elseif n<(p+2)*(p+2) return true end
  end
  return "Maybe"
end
function isPrime!(n=35;method=1,debug=0,primes=primes)
  if method==1 isprime= isPrime(n;debug=debug,primes=primes)
  elseif method==2 isprime= findOneFactor!(n;primes=primes,debug=debug)==n
  else throw(" method $method not Known, use 1 or 2")
  end
  if isprime=="Maybe"&& extendPrimes!(n;method=method,primes=primes,debug=debug-1)
    return isPrime!(n;method=method,debug=debug,primes=primes)
  else return isprime
  end
end

function findNextPrime(primes=primes; method=1, potPrime=primes[end]+2,debug=0)
  if !isnothing(indexin(1,primes)[1]) throw("1 should not be in the potential divisor list") end
  if debug>0 print( "primes: ") end
  while !isPrime!(potPrime; method=method, debug=debug-1, primes=primes) potPrime+=2 end
  if debug>0 print( " a new prime: $potPrime. ") end
  return potPrime
end

function addPrimesUntil!(needed=43;method=1,primes=primes,debug=0)
  start=primes[end]+2
  nradded=0
  if method==1
    for pp=start:2:needed
        for p in primes[2:end]
            if pp%p==0 break
            elseif pp < (p+2)*(p+2)
                push!(primes,pp)
                nradded+=1
                break
            end
        end
    end
  elseif method==2
    prime=start-2
    while prime<=needed
      prime=findNextPrime(primes; method= 1,debug=debug-1, potPrime=prime+2)
      push!(primes,start)
      nradded+=1
    end
  else throw("method $method unknown")
  end
  return nradded
end

function extendPrimes!(n=60;primesNeeded=0, method=1,primes=primes,debug=0)
  lastp2=(primes[end]+2)
  primesNeeded = max(primesNeeded,ceil(BigInt,sqrt(n)))
  if debug>0
      print(" Extending with primes from highest known prime ", primes[end], " to the last prime <= $primesNeeded ")
    end
  return addPrimesUntil!(primesNeeded;method=method, debug=debug-1, primes=primes)>0
end

function addPrime!(nr=1;method=1,primes=primes,debug=0)
    prime=primes[length(primes)]
    for k=1:nr
          prime=findNextPrime(primes;method= method,debug= debug-1, potPrime=prime+2)
          push!(primes,prime)
        if debug>2 println(primes) end
    end
    return prime
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
  if debug>=5 print(primes , " the primes as in factorUsing ") end
  for p in primes
      if !composite
        if n< p*p if factors==[] push!(factors,n) ; n=1;nr-=1 end; break end
      elseif n<p+p push!(factors,n);nr-=1 ; break end
      if n%p==0
          push!(factors,p)
          if debug >= 1 print("factor: $p, ") end
          if !composite n = n ÷ p end
          nr-=1; if nr==0 break end
          if !composite && n>1
            (n,nr,factors2)=factorUsing(n,nr; primes=primes[indexin(p,primes)[1]:end],debug=debug) #primes not appended onto, so can subset
            append!(factors, factors2)
            break
          end
      end
  end
  if n==1 || composite    DivList[originaln] = factors end
  return (n,nr,factors)
end

function factor!(n=60:Int128, compositeFactors=false, extendPrimes=true;nr=-1,startindex=1,potFactors=primes,debug=0)
  originaln=n
  if debug>=1 print(" factoring $n into $nr factors ",debug>4 ? potFactors[startindex:end] : "", extendPrimes ? " and extend" : " ") end
  n,nr,factors=factorUsing(n,nr,compositeFactors;primes=potFactors[startindex:end],debug=debug)
  if extendPrimes && n>1 && nr!=0
    startindex=length(potFactors)+1
    if extendPrimes!(n;method=1,primes=potFactors)
      n,nr,factors2=factor!(n,compositeFactors,extendPrimes;nr=nr,startindex=startindex,potFactors=potFactors,debug=debug-1)
      append!(factors,factors2)
    else
      if debug>1 println(" no factors in $n but no extension of $primes was made! then $n is prime itself") end
      (push!(factors,n))
      n=1;nr=nr-1
    end
  end
  if !compositeFactors
      if n==1 if debug>0 print(get(PrimeDivisors,originaln,"factors of $originaln not yet stored")) end;
        global PrimeDivisors[originaln] = factors
      elseif nr>0 throw("while factoring $originaln there is $n left over, $nr factor still allowed, factors found: $factors")
      end
  end
  return n,nr,factors
end

function findOneFactor!(n=60;primes=primes,debug=0)
  return factor!(n,false,true;nr=1,potFactors=primes,debug=debug)[3][1]
end
# this is the end of the prime searching. now for the decompositions:
function PrimeDecomposition!(n=43;extend=true,primes=primes,debug=0)
  if !@isdefined(PrimeDivisors) global PrimeDivisors= Dict{Integer,Array{Integer}}() end #(4 => [2]) end
  factors= get(PrimeDivisors,n,BigInt[] )
  if factors!=[] return factors
  else
    PrimeDivisors[n]=  factor!(n,false,extend;potFactors=primes,debug=debug)[3]
  end
end

function findDivisorswithMultiplicity!(n; primes=primes, debug=0)
  if !@isdefined(DivisorsMult) Divisors = Dict{Integer,Array{Integer}}() end
  result = get(DivisorsMult,n,[])
  if result!=[] return result end
  #while primes[length(primes)]^2<n addPrime!(2) end
  primedivs=PrimeDecomposition!(n; primes=primes, debug=debug-1)
  divisorswithMultiplicity = [1]
  for p in primedivs
    divisorswithMultiplicity = append!(divisorswithMultiplicity, divisorswithMultiplicity.*p)
  end
  DivisorsMult[n]= divisorswithMultiplicity
  return (divisorswithMultiplicity)
end

function Divisors!(n;debug=0)
  res=get(Divisors,n,[])
  if res==[]  Divisors[n] = res = factor!(n,true,false;potFactors=collect(2:n), debug=debug-1)[3] end
  return res
end
function sumDivisors(n;debug=0)
  if !@isdefined(DivisorSum) global DivisorSum = Dict{Integer,Integer}() end
  res= get(DivisorSum,n,[])
  if res==[]  DivisorSum[n] = res= 1+sum(Divisors!(n,debug=debug-1)) end
  return res
end


function isPerfect(n; debug=0)
  return sumDivisors(n,debug=debug-1)==n+n
end


function multiPerfect(n; debug=0)
  if !@isdefined(RelDivSum) global RelDivSum = Dict{BigInt,Float64} end
  if !@isdefined(RelDivSumInt) global RelDivSumInt = Dict{BigInt,Integer} end
  res = get(RelDivSum,n,0.0)
  if res==0 RelDivSum[n]= (sumDivisors(n))/n end
  resInt=get(RelDivSumInt,n,0)
  if resInt==0 && sum%n==0 RelDivSumInt[n]=sumDivisors(n) end
  return sumDivisors(n,debug=debug-1)%n==0
end

function sumDivisorsMultiply(n;debug=0)
  if !@isdefined(DivisorsMultSum) DivisorsMultSum = Dict{Integer,Integer}() end
  res= get(DivisorsMultSum,n,[])
  if res==[] DivisorsMultSum[n] = res= sum(findDivisorswithMultiplicity!(n;debug=debug-1)) end
  return res
end

function isVeryPerfect(n; debug=0)
  a= sumDivisorsMultiply(n,debug=debug-1)
  if isodd(debug) print(n," ") end
  if  debug >= 2
    if a==n+n  print("perfect ")
    elseif a<n+n  print("thin ")
    elseif a>n+n print("fat ")
    end
  end
  return a==n+n
end

function amico(n;cyclelength=2, debug=0)
  a=n
  for k = 2:cyclelength a=sumDivisors(a,debug=debug-1)-a end
  return n==sumDivisors(a,debug=debug-1)-a ? a : 0
end
function moltoamico(n;cyclelength=2,debug=0)
  a=n
  for k=2:cyclelength a=sumDivisorsMultiply(a,debug=debug-1)-a end
  return n==sumDivisorsMultiply(a,debug=debug-1)-n ? a : 0
end
## unittests
primes=[2,3]
isPrime(35)
isPrime!(35)
primes'

primes=[2,3]
extendPrimes!(1000;primesNeeded=3, method=1,debug=67)
primes'
isPrime(997)
isPrime(1031)
addPrimesUntil!(30)
findNextPrime(method=1,debug = 5)#does not append them!
findNextPrime(method=2,debug=5)

factorUsing(4)
factorUsing(5)
factorUsing(6)
factorUsing(6)[3]
factorUsing(7)
factorUsing(8)
factorUsing(9)
factorUsing(10)
factorUsing(11)
factorUsing(23)
factorUsing(24)
factorUsing(25)
factorUsing(29)
factorUsing(125)
factorUsing(35)
primes'
primes=[2,3]
PrimeDecomposition!(6,debug=0)
PrimeDecomposition!(11,extend=false,primes=primes,debug=10)
PrimeDecomposition!(35,extend=false,primes=primes,debug=10)
PrimeDecomposition!(11,debug=0)
primes'
PrimeDecomposition!(35,debug=10)
primes'

PrimeDecomposition!(77,debug=10)
primes'
PrimeDecomposition!(997,debug=10)
findOneFactor!(6)
findOneFactor!(11)
findOneFactor!(79)
findOneFactor!(121)

PrimeDecomposition!(60)
Divisors!(60)
primes'
addPrimesUntil!(40,method=2)
addPrime!(1,method=1,primes=primes,debug=0)
addPrime!(1,method=2)
addPrime!(1,method=2,debug=7)

for i=1:2
  print( "method $i ");@time(begin global primes=[2,3];extendPrimes!(5000; method= i, primes=primes);primes' end)
end

for i=1:2
  print( "method ",i," ");@time(begin global primes=[2,3];addPrime!(5000;method= i, primes=primes);primes' end)
end
primes1=[2,3]; primes2=[2,3];
addPrime!(5000, method=1, primes=primes1)
addPrime!(5000, method=2, primes=primes2)
primes1==primes2

#===========================
method 1   1.024183 seconds (104.58 k allocations: 1006.703 MiB, 15.00% gc time)
method 2   1.265096 seconds (245.81 k allocations: 1.469 GiB, 18.77% gc time)
it seemed in earlier versions isPrime was the best way of just searching for primes.:
not much less time but hugely less memory: some hundred MB instead of 1 GB
===========================#
primes=BigInt[2,3]
@assert PrimeDecomposition!(28,extend=false)==[2,2,7]
@assert factor!(28, true,false)[3]==[2]
@assert PrimeDecomposition!(28)==[2,2,7]
#does not need to extend variable primes if n<=(largest prime+2)^2, so not here yet
@assert PrimeDecomposition!(25)==[5,5] # even if not extended yet
@assert PrimeDecomposition!(21,extend=false)==[3,7]
@assert PrimeDecomposition!(35)==[5,7] # this added 5, not 7  !!
extendPrimes!(35)
primes'
prod7=2*3*5*7*11*13*17
prod8=prod7*19
prod11=prod8*23*29*31
extendPrimes!(prod7)
@time(PrimeDecomposition!(prod7,extend=false;primes=collect(2:prod7)))
@time(Divisors!(prod7)) #note: use collect(2:prod7)
@time(PrimeDecomposition!(prod7,extend=false,primes=collect(2:prod7))) #note: use collect(2:prod7)
pots=collect(2:20)
@time(PrimeDecomposition!(41*43,extend=true,debug=20,primes=collect(2:prod7)))
@time(factor!(prod7+1,true,false;potFactors=collect(2:(prod7+1))))
primes'
@assert primes==[2,3]
@assert factor!(28, true,true)[3] == [2,7]
@assert findOneFactor!(28)== 2 #7 not in primes yet
@assert PrimeDecomposition!(28)==[2,2,7] #
@assert PrimeDecomposition!(28)==[2,2,7] #returns [2,2,7]
PrimeDecomposition!(28)
PrimeDecomposition!(2*2*3*11)=[2,2,3,11],
# not meant to find 7 new primes, but finds some small prime anyway.
primes'
@assert PrimeDecomposition!(28)==[2,2,7] # this function adds new primes
primes'
@assert( Divisors!(28) ==[2,4,7,14,28])
@assert PrimeDecomposition!(2*2*3*7*7)==[2,2,3,7,7]#
#PrimeDecomposition!!(2*2*3*7*7)
@assert PrimeDecomposition!(17017)==[7,11,13,17]  #adds 11,13,17 to primes
@assert PrimeDecomposition!(prod7^2)==[2,2,3,3,5,5,7,7,11,11,13,13,17,17]
@assert
PrimeDecomposition!((prod7+1)^2)
==BigInt[]  #19,19,19,97,97,97,277,277,277 not yet found
@assert PrimeDecomposition!(prod7+1)==[19,97,277]  #adds primes up to 277
@assert PrimeDecomposition!((prod7+1)^2)==BigInt[19,19,97,97,277,277] #found
## now do some timing
@time( for n=4:46 println(n," ",PrimeDecomposition!(n)) end) # klopt!
@time( for n=4:46 println(n, factor!(n)[3]) end) #same thing!
@time( for n=4:20 println(n,factor!(n,true,potFactors=primes)) end)
# should find each factor exactly once! but finds n twice, sometimes.


@time(begin primes=[2,3];addPrime!(50,debug=3);primes' end)
@time(PrimeDecomposition!(prod7))
@time(PrimeDecomposition!(prod7+1))
@time(Divisors!(prod7+1))
@time(Divisors!(prod7+1))
PrimeDecomposition!(prod7+1)
print(primes')
@time(PrimeDecomposition!(prod7))
@time(addPrime!(24))
@time(addPrime!(25))
@time(addPrime!(25))
@time(addPrime!(25))
@time(addPrime!(200))
print(primes')
##test Dict making
@assert sumDivisors(28)==28+28
Divisors[28]
@assert(isPerfect(28))
@time([i for i = 1:500 if isPerfect(i)])
Divisors
DivisorSum
multiPerfect(28)

## test perfection
@assert isVeryPerfect(6)
@assert !isPerfect(29,2)

@time([i for i = 1:10000 if isPerfect(i)]) # takes 94 seconds on Acer2.
@time(begin n=100; print("Perfect numbers until ",n,": ");for i in 1:n isPerfect(i) end end)
# [1,6,28,496,8128]
@time(@assert begin n=1000; print("Perfect numbers until ",n,": ");
     [i for i in 1:n if isPerfect(i,0)==0]  end ==[1,6,28,496])
     # 0.141507 seconds (141.29 k allocations: 5.286 MiB)
primes=[2,3]
addPrime!(100)
@assert findDivisorswithMultiplicity!(28)==[1,2,2,4,7,14,14,28]
for i in 2:20
  list= findDivisorswithMultiplicity!(i)
  println(length(list)," divisors of ",i,": ", list )
end
@time(@assert begin n=1000; print("very Perfect numbers until ",n,": ");[i for i in 1:n if isVeryPerfect(i,debug=0)] end==[6])
#0.468230 seconds (226.86 k allocations: 77.772 MiB, 7.55% gc time)
@time(begin n=100; print("verysumdivisors numbers until ",n,": ");[ n for i in 1:n if isVeryPerfect(i)] end)
@time(  for i in 1:1001 if isVeryPerfect(i)==0 println(i, " is very perfect")end end)
# until 100001 was 145.212405 seconds (35.06 M allocations: 114.396 GiB, 11.57% gc time)
# only 6 is very perfect below 100001
@time( @assert [[n,amico(n)]  for n in 1:1001 if amico((n))!=0] ==[[1,1],[6,6],[28,28],[220,284],[284,220],[496,496]]) #36,55  not symmetric?
@time( @assert [[n,amico(n,cyclelength=3)]  for n in 1:1001 if amico(n,cyclelength=3)!=0]==[[6,6],[28,28],[496,496]])
@time( @assert [[n,amico(n,cyclelength=4)]  for n in 1:1001 if amico(n,cyclelength=4)!=0]==[[6,6],[28,28],[220,284],[284,220],[496,496]])
@time( [[n,amico(n,cyclelength=5)]  for n in 1:1001 if amico(n,cyclelength=5)!=0]==[[6,6],[28,28],[496,496]])
@time( [[n,amico(n,cyclelength=6)]  for n in 1:1001 if amico(n,cyclelength=6)!=0]==[[6,6],[28,28],[220,284],[284,220],[496,496]])
@time( [[n,amico(n,cyclelength=7)]  for n in 1:1001 if amico(n,cyclelength=7)!=0]==[[6,6],[28,28],[496,496]])
@time( [[n,amico(n,cyclelength=8)]  for n in 1:1001 if amico(n,cyclelength=8)!=0]==[[6,6],[28,28],[220,284],[284,220],[496,496]])
[[n,amico(n,cyclelength=8)]  for n in 1:10001 if amico(n,cyclelength=8)!=0]
@time( [[n,moltoamico(n,cyclelength=1)]  for n in 1:1001 if moltoamico(n,cyclelength=1)!=0]) # 0.799494 seconds
@time( [[n,moltoamico(n,cyclelength=2)]  for n in 1:1001 if moltoamico(n,cyclelength=2)!=0]==[[6,6],[20,34],[34,20],[765,963],[963,765]]) #16.942204
@time( [[n,moltoamico(n,cyclelength=3)]  for n in 1:1001 if moltoamico(n,cyclelength=3)!=0])==[[6,6]]
# 338.246336 seconds (2.59 G allocations: 66.644 GiB, 28.81% gc time)

@time( [[n,moltoamico(n,cyclelength=4)]  for n in 1:101 if moltoamico(n,cyclelength=4)!=0]==[[6,6],[20,34],[34,20]]) #2.594176
@time( [[n,moltoamico(n,cyclelength=4)]  for n in 1:1000 if moltoamico(n,cyclelength=4)!=0]) # ==[[6,6],[20,34],[34,20]]) #2.594176

@time( [[n,moltoamico(n,cyclelength=5)]  for n in 1:101 if moltoamico(n,cyclelength=5)!=0]) #22.695123
@time( [[n,moltoamico(n,cyclelength=6)]  for n in 1:101 if moltoamico(n,cyclelength=6)!=0])
@time( [[n,moltoamico(n,cyclelength=7)]  for n in 1:101 if moltoamico(n,cyclelength=7)!=0])
@time( [[n,moltoamico(n,cyclelength=8)]  for n in 1:101 if moltoamico(n,cyclelength=8)!=0])

@time( [n  for n in 1:101 if multiPerfect(n)])
 

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
