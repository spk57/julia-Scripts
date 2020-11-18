#Password.jl

#Generate a random password

 

len=16

fullChars="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz,.;':[]{}|1234657890-=_+!@#\$%^&**()"

fewChars="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234657890=!-@_*."

 

function randomPassword(chars=fewChars)

  numChars=length(chars)

  p=""

  for i in 1:len

#    global p

    c=rand(1:numChars)

    p=p*chars[c]

  end

  return p

end

 

println(randomPassword())
