module Jetelina

#using Genie, Logging, LoggingExtras

# this using descri due to g5test
using Genie
# this define and export due to g5test
const up = Genie.up
export up

function main()
# these commented out are due to g5test

#  Core.eval(Main, :(const UserApp = $(@__MODULE__)))

  Genie.genie(; context = @__MODULE__)

#  Core.eval(Main, :(const Genie = UserApp.Genie))
#  Core.eval(Main, :(using Genie))
end

end
