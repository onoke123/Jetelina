module timertest

    function __init__()
        t = Timer(test,2,interval=2)
        wait(t)
        sleep(1.0)
        close(t)
    end

    function test(timer)
        @show "test()"
    end
end