module Oldpounds
export LSD
mutable struct LSD
   pounds::Int
   shillings::Int
   pence::Int

   function LSD(a=0, b=0, c=0)
    if a < 0 || b < 0
      error("no negative numbers")
    end
    if c >= 12
      b+= c÷12
      c%=12
    end
    if b >= 20
      a+=b÷20
      b%=20
    end
    new(a, b, c)
   end
end

function Base.:+(a::LSD, b::LSD)
    LSD(a.pounds + b.pounds, a.shillings + b.shillings, a.pence + b.pence)
end

function Base.show(io::IO, money::LSD)
    print(io, "$(money.pounds)£$(money.shillings)s$(money.pence)d")
end

end

### usage
import Oldpounds.LSD
price1=(LSD(1,20,13))
fieldnames(typeof(price1))
price1.pounds
(LSD(1,19,12))
(LSD(1,0,12))
#LSD(-1,0,0)
price2=LSD(20,20,20)
(price1+price2)
