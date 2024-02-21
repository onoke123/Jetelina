module timertest
    using Dates

    stopper = Ref(false)

    function dosomething(interval)
    #    global stopper = Ref(false)
        i=0
        task = @async while !stopper[]
            hi(i)
            i += 1
            sleep(interval)
        end
    end

    function stopsomething()
        stopper[] = true
    end

    function hi(i::Integer)
        if 0<i
            str = string(i,":",Dates.format(now(), "yyyy-mm-dd HH:MM:SS"), "hi ho")
            println(str)
        end
    end
end