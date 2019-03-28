function findFactor(n=3,primes=[2,3],nr=0,extend=true, startindex=1,debug=0)
    factors=BigInt[]
    if n==1 || startindex>length(primes)|| startindex<1 return factors end
    if debug>1 print(n,", ") end
    for p in primes[startindex:end]
        if n%p==0
            push!(factors,p)
            if n!=p && nr!=1
                append!(factors,
                  findFactor(div(n,p),primes,nr-1,true,indexin(p,primes)[1]))
            end
            return factors
        elseif n<p*p && factors==[] push!(factors,n) ;break end
    end
    if extend &&(typeof(n)<:Integer)
        while length(factors)==0
           p=addPrime!(primes,1)
           if n%p==0
               push!(factors,p)
               if n!=p && nr!=1
                   append!(factors,
                      findFactor(div(n,p),primes,nr-1,true, indexin(p,primes)[1]))
               end
               return factors
            end
        end
    end
    return factors
end

# if you are sure primes contains all relevant primes, specify it.
# if afraid you might miss a factor, dont specify, and loop over all integers
function isPrime(n=510511,primes=[])
    isprime=true
    if length(primes)==0 primes=2:floor(BigInt,sqrt(n)) end
    for k in primes
        if n%k==0
            isprime=false
        end
    end
    return isprime
end

function addPrime!(primes=[2,3],n=1,method=2)
    potPrime=primes[length(primes)]+2
    for k=1:n
        potPrime=primes[length(primes)]+2
        if (method==1)
            while !isPrime(potPrime,primes) potPrime+=2 end
        elseif method==2
            while length(findFactor(potPrime,primes,1,false,1))>0 potPrime+=2 end
        end
        push!(primes,potPrime)
    end
    return potPrime
end

function addPrimesUntil!(n=42*43;method=0,primes=primes,debug=0)
    start=primes[end]+2
    for i=start:2:n
        for p in primes[2:end]
            if i < p*p
                push!(primes,i)
                break
            elseif i%p==0
                break
            else  print(debug>1 ? " $p^2<$n" : "") ;continue end
        end
    end
    return primes'
end
primes=[2,3]
addPrimesUntil!(43*41,debug=0)
primes'
for i=3:2:13
    print("we loop over i=$i:")
  for p = 2:(i^3)
      if p*p>i   break end
      print("$p,")
  end
  println(". ")
end

##
collect(5:2:43)'
findFactor(7,primes,0,true)
@time(addPrime!(primes,2))
@time(begin primes=[2,3]
      addPrime!(primes,200,1) end)
@time(begin primes=[2,3]
      addPrime!(primes,200,2) end)

print(primes')
@time(isPrime(4))
biggie=510510
@time(isPrime(510511))
@time(isPrime(510511,primes))
@time( findFactor(biggie+1,primes,) )
start=1000; endnr=10000
@time( for n =start:endnr findFactor(n) end)
@time( for n =start:endnr findFactor(n,primes) end)
@time( for n =start:endnr isPrime(n) end)
@time( for n =start:endnr isPrime(n,primes) end)

function isPerfect(n=28,primes=primes)
    factors=findFactor(n,primes,0,true)
    return sum(factors)+1== n
end
primesold=primes
primes=[2,3]

isPerfect(6)
isPerfect(5)
for i=1:1000 isPerfect(i) ? print(i, " perfect, ") : print(" ") end
print(primes')
isPerfect(10)
primes'
