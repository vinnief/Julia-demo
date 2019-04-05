## prime number generation and factorization
#module findPrimes
#export isPrime, isPerfect,isVeryPerfect, PrimeDivisors, Divisors!,amico,
#      nextfriend, countClingy,primes
function init(;force=false)
  if force || !@isdefined(primes) || primes==[] global primes=[2,3] end
  if force || !@isdefined(Divisors)              global Divisors = Dict{Integer,Array{Integer}}() end #(4 => [2])
  if force || !@isdefined(DivisorsMult)          global DivisorsMult = Dict{Integer,Array{Integer}}() end #(12 =>[1,2,2,3,4,6,6,12]) or (12 => [2,2,3,4,6,6])
  if force || !@isdefined(PrimeDistinctDivisors) global PrimeDistinctDivisors=Dict{Integer,Array{Integer}}() end #(4 => [2])
  if force || !@isdefined(PrimeDivisors)         global PrimeDivisors= Dict{Integer,Array{Integer}}() end #(4 => [2,2])
  if force || !@isdefined(DivisorSum)            global DivisorSum = Dict{Integer,Integer}() end
  if force || !@isdefined(relDivSum)             global relDivSum = Dict{Integer,Float64}() end
  if force || !@isdefined(relDivSumInt)          global relDivSumInt = Dict{Integer,Integer}() end
  if force || !@isdefined(clingCycle)            global clingCycle=Dict{Integer,Array{Integer}}()end
end
init() #force=true)

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
    DivList=Divisors
  else
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
  factors= get(PrimeDivisors,n,BigInt[] )
  if factors!=[] return factors
  else
    PrimeDivisors[n]=  factor!(n,false,extend;potFactors=primes,debug=debug)[3]
  end
end

function findDivisorswithMultiplicity!(n; primes=primes, debug=0)
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
  if !@isdefined(RelDivSum) global RelDivSum = Dict{Integer,Float64} end
  if !@isdefined(RelDivSumInt) global RelDivSumInt = Dict{Integer,Integer} end
  res = get(RelDivSum,n,0.0)
  if res==0.0 RelDivSum[n]= (sumDivisors(n))/n end
  resInt=get(RelDivSumInt,n,0)
  if resInt==zero(resInt) && sum%n==zero(n) RelDivSumInt[n]=sumDivisors(n) end
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

nextFriend(n::Integer; debug=0)= n<=1 ? n : sumDivisors(n)-n

function countClingy(n::Integer; upperlevel= 1000 , maxCount=1000,debug=1)
  if !@isdefined(clingCycle) global clingCycle=Dict{Integer,Array{Integer}}() end
  a=n;conte=0;res=[]#get(clingCycle,n,[])
  while conte<maxCount && isnothing(indexin(a,res)[1])
     conte+=1;  push!(res,a)
     if debug>4 print("$a ")end
     a=nextFriend(a)
   end
   push!(res,a)
   steps=indexin(a,res)[1]
   if steps!=length(res)
     if debug>=1 &&res[end]!= 1 println("$n ends in $steps steps in a cycle  which is ", length(res)-steps ," long. Cycle is:", res[steps:end]) end
   else
     if debug>=1 println("no cycle in $steps=$maxCount steps") end
   #elseif a==0 steps=length(res)
   end
   clingCycle[n]=res
   #if debug>2 println("$n ",length(res), " ", res[max(1,end-4):end]) end
  return length(res)-steps , steps,conte,res
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
#end # module findPrimes.jl
