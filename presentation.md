
 ██████╗ ███████╗███╗   ██╗      ███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗ ███████╗
██╔════╝ ██╔════╝████╗  ██║      ██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗██╔════╝
██║  ███╗█████╗  ██╔██╗ ██║█████╗███████╗█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝███████╗
██║   ██║██╔══╝  ██║╚██╗██║╚════╝╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗╚════██║
╚██████╔╝███████╗██║ ╚████║      ███████║███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║███████║
 ╚═════╝ ╚══════╝╚═╝  ╚═══╝      ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝╚══════╝


.88b  d88.  .d88b.  d8888b. d88888b      d888888b db   db  .d8b.  d8b   db      
88'YbdP`88 .8P  Y8. 88  `8D 88'          `~~88~~' 88   88 d8' `8b 888o  88      
88  88  88 88    88 88oobY' 88ooooo         88    88ooo88 88ooo88 88V8o 88      
88  88  88 88    88 88`8b   88~~~~~         88    88~~~88 88~~~88 88 V8o88      
88  88  88 `8b  d8' 88 `88. 88.             88    88   88 88   88 88  V888      
YP  YP  YP  `Y88P'  88   YD Y88888P         YP    YP   YP YP   YP VP   V8P      

                                                                                
.88b  d88. d88888b d88888b d888888b .d8888.      d888888b db   db d88888b 
88'YbdP`88 88'     88'     `~~88~~' 88'  YP      `~~88~~' 88   88 88'     
88  88  88 88ooooo 88ooooo    88    `8bo.           88    88ooo88 88ooooo 
88  88  88 88~~~~~ 88~~~~~    88      `Y8b.         88    88~~~88 88~~~~~ 
88  88  88 88.     88.        88    db   8D         88    88   88 88.     
YP  YP  YP Y88888P Y88888P    YP    `8888Y'         YP    YP   YP Y88888P 
                                                                          
                                                                          
d88888b db    db d88888b 
88'     `8b  d8' 88'     
88ooooo  `8bd8'  88ooooo 
88~~~~~    88    88~~~~~ 
88.        88    88.     
Y88888P    YP    Y88888P 

# Three Primitives Required for Concurrency

1. Spawning new processes
2. Sending messages
3. Receiving messages

## 1. Spawning a New Process

    iex(1)> f = fn() -> 2 + 2 end
    #Function<20.99386804/0 in :erl_eval.expr/5>
    iex(2)> spawn(f)
    #PID<0.94.0>

The result is a process identifier (or PID for short).

To see the result, print out value:

    iex(3)> spawn(fn() -> IO.puts("#{2+2}") end)  
    4
    #PID<0.108.0>

Start 10 functions:

    iex(4)> g = fn(x) -> :timer.sleep(10); IO.puts("#{x}") end
    #Function<6.99386804/1 in :erl_eval.expr/5>
    iex(5)> for x <- 1..10, do: spawn(fn() -> g.(x) end)
    [#PID<0.112.0>, #PID<0.113.0>, #PID<0.114.0>, #PID<0.115.0>, #PID<0.116.0>,
    #PID<0.117.0>, #PID<0.118.0>, #PID<0.119.0>, #PID<0.120.0>, #PID<0.121.0>]
    3
    1
    2
    4        
    5        
    6        
    7        
    8        
    9        
    10       

Shell itself is a process:

    iex(6)> self()
    #PID<0.85.0>
    
## 2. Sending Messages

    iex(1)> send(self(), :hello)
    :hello

Message is sent but not read yet.

    iex(2)> send(self(), :world)
    :world
    iex(3)> send(self(), :world)
    :world

To see contents of mailbox for a shell use:

    iex(4)> flush()
    :hello
    :world
    :world
    :ok

## 3. Receiving Messages

Let's write a simple program: dolphins.ex.

Compile it in the shell:

    iex(1)> c("dolphins.ex")
    [Dolphins]

Spawn a dolphin process:

    iex(2)> dolphin = spawn(Dolphins, :dolphin1, [])
    #PID<0.99.0>
     
    iex(3)> send dolphin, "oh, hello dolphin!"
    Heh, we're smarter than you humans.
    "oh, hello dolphin!"

Re-start process (since it terminated):

    iex(4) dolphin = spawn(Dolphins, :dolphin1, [])
    iex(5)> send dolphin, :fish                    
    So long and thanks for all the fish!
    :fish
 
 Here the spawn function takes a Module, Function and Arguments. Once function
 is running it:

 1. Hits the receive statement
 2. Mailbox is empty. Waits...
 3. When message is received it is matched against a given pattern.
 4. _ is a catch-all pattern.

# Replying to Messages

Instead of printing, we can reply. See dolphin2 in dolphins.ex.

We now require `From`, this is a process identifier:

    iex(1)> c("dolphins.ex")
    [Dolphins] 

    iex(2)> dolphin2 = spawn(Dolphins, :dolphin2, [])
    #PID<0.141.0>

    iex(3)> send dolphin2, {self(), :do_a_flip}
    {#PID<0.85.0>, :do_a_flip}

We need to flush to see the messages we got:

    iex(4)> flush()
    "How about no?"
    :ok
    
# Recursion

To solve the problem of the process always terminating, we need
to call the function again to receive more messages.

See dolphin3 in dolphins.ex. 

    iex(1)> c("dolphins.ex")                         
    [Dolphins]
    iex(2)> dolphin3 = spawn(Dolphins, :dolphin3, [])
    #PID<0.153.0>

Now process will keep going:

    iex(3)> send dolphin3, {self(), :do_a_flip}
    {#PID<0.85.0>, :do_a_flip}
    iex(4)> send dolphin3, {self(), :do_a_flip}
    {#PID<0.85.0>, :do_a_flip}
    iex(5)> flush()
    "How about no?"
    "How about no?"
    :ok

Sending `:fish` message wil stop the process:

    iex(6)> send dolphin3, {self(), :fish}     
    {#PID<0.85.0>, :fish}
    iex(7)> flush()
    "So long and thanks for all the fish!"
    :ok

# Storing State

We need to be able to store state.

## Fridge

Let's implement a fridge, that provides two operations:

1. Store food
2. Take food

See `fridge1` in kitchen.ex

Let's store some food in the fridge and try to take some out:

    c("kitchen.ex")   
    fridge = spawn(Kitchen, :fridge1, [])  
    send fridge, {self(), {:store, :apple}}
    
See that we got a reply:

    flush()
    > {#PID<0.228.0>, :ok}

Now let's try to take some food: 

    send fridge, {self(), {:take, :apple}} 
    flush()
    > {#PID<0.228.0>, :not_found}
    
## Fridge with Memory

We can store state in the parameters of the recursive function.
See `fridge2` in kitchen.ex

Let's store some food in the fridge:

    c("kitchen.ex")
    fridge = spawn(Kitchen, :fridge2, [[:baking_soda]])  
    send fridge, {self(), {:store, :milk}}
    send fridge, {self(), {:store, :bacon}}
    flush()
    > {#PID<0.248.0>, :ok}
    > {#PID<0.248.0>, :ok}
    > :ok

and now take some out:

    send fridge, {self(), {:take, :bacon}}
    send fridge, {self(), {:take, :turkey}}
    flush()
    > {#PID<0.262.0>, {:ok, :bacon}}
    > {#PID<0.262.0>, :not_found}
    > :ok

## Fridge with Memory and Secret Messages    

Sending messages to a process is annoying. 
What we really want to do something like `Kitchen.store`.
It is also annoying to "spawn" processes all the time.

Let's write an API for our process to hide the messages, and process 
spawning. See "kitchen.ex".

Now we can interact with our process in a nice way:

    c("kitchen.ex")
    kitchen = Kitchen.start([:baking_soda])

    Kitchen.store(kitchen, :water)
    > :ok

    Kitchen.take(kitchen, :water) 
    > {:ok, :water}

    Kitchen.take(kitchen, :juice)
    > :not_found

## Fridge with Timeout

Let's try to issue a call to a non-existant process:

    Kitchen.take(pid(0,250, 0), :juice)

Receive waits for new message and never gets it. 
We need to place a timeout. For this we use the "after" clase of receive construct.

See kitchen.ex, and let's try it:

    c("kitchen.ex")
    Kitchen.take(pid(0,250,0), :beans)

# Links, Traps and Monitors

Now we will look at how to handle errors when processes fail.

Link is a relationship between two processes, such that if
one process fails, it makes the other process fail as well.

Useful when we depend on some process and it crashes.
Often better to restart all at the same time to recover.

See "linkmon.ex"

Notice it only crashes the shell if we link to it:

    spawn(&Linkmon.myproc/0)           
    > #PID<0.146.0>

    Process.link(spawn(&Linkmon.myproc/0))
    > true     
    > ** (EXIT from #PID<0.140.0>) evaluator process exited with reason: :reason

Spawn & link is prone to failure, since it can die before link is established.
So there is a function that does both at once:

    spawn_link(&Linkmon.myproc/0)         
    > #PID<0.109.0>                                 
    > ** (EXIT from #PID<0.107.0>) evaluator process exited with reason: :reason


Trapping allows us to intercept the "EXIT" message. The process must set a flag:

    Process.flag(:trap_exit, true)

Now when we link to a failing process, we don't crash:

    Process.link(spawn(&Linkmon.myproc/0))

But instead get a message:

    flush()
    > {:EXIT, #PID<0.152.0>, :reason}

Monitors are like links but are:

1. Unidirectional
2. Can be stacked (unlike links, which can't unlink an idividual prcoess)

Let's setup a monitor:

    :erlang.monitor(:process, spawn(fn() -> :timer.sleep(5000) end))
    > #Reference<0.3296726473.3772514305.201422>

    flush()
    > {:DOWN, #Reference<0.3296726473.3772514305.201422>, :process, #PID<0.87.0>,
    > :normal}
   

Just like links, there is a race condition between spawning and monitoring
a process. So we have an operation that does both:

    {pid, ref} = spawn_monitor(fn() -> receive do _ -> exit(:boom) end end)
    > {#PID<0.120.0>, #Reference<0.3296726473.3772514305.202060>}

    send pid, :die
    > :die    

    flush()
    >{:DOWN, #Reference<0.3296726473.3772514305.202060>, :process, #PID<0.120.0>,
    > :boom}

Reference is there to allow us to demonitor the process.

    {pid, ref} = spawn_monitor(fn() -> receive do _ -> exit(:boom) end end)
    > {#PID<0.120.0>, #Reference<0.3296726473.3772514305.202060>}

    :erlang.demonitor(ref)

    send pid, :die
    > :die    

    flush()
    > :ok

# Names

## The problem

There is a problem if we keep using process ids to send messages.

Consider a chef program in "chef.ex", that accepts orders for
a dish and a temperature to cook it at.

    c("chef.ex")
    chef = Chef.start_chef()          

    Chef.cook(chef, "steak", "rare")  
    > "Excellent choice!"

    Chef.cook(chef, "chicken", "rare")
    > "What is wrong with you?"

Now consider what happends when the chef process is gone:

    Process.exit(chef, :heart_attack)
    Chef.cook(chef, "fish", "well done")
    > :timeout

## The First Solution

We need to restart the process, and register the name in the
global name registry. See `start_chef`, `restarter`, `cook` in "chef.ex".

Cook no longer takes a pid and we can refer to different processes
by the same name:

    c("chef.ex")  
    Chef.start_chef()
    Chef.cook("steak", "rare")
    > "Excellent choice!"

    Process.exit(Process.whereis(:chef), :heart_attack)   
    Chef.cook("steak", "well done")  
    > "Get out of my restaurant!"

Note, there is a need to match against a pid, so that we know the chef
process replied to us. But there is a problem... what if between:

    send :chef, {self(), {dish, temperature}}
    pid = Process.whereis(:chef)

the process dies? The `whereis` will fail, program will crash!
Other nasty cases.

## The Second Solution

Instead of chef replying with its own pid, it replies with a unique reference
we sent it instead.
See `cook` and `chef` in "chef.ex". It still works as expected:

    ^C-a
    iex
    c("chef.ex")
    Chef.start_chef()

    Chef.cook("steak", "rare")
    > "Excellent choice!"

    Chef.cook("chicken", "hot")    
    > "Coming right up!"

# Client-Server abstraction

Client sends calls to the server, and server replies.

We implemented in the chef example: chef was the server process, and
the shell was the client. This is very common pattern.

## Kitty Shop

Let's create a cat shop. See `kitty_server.ex` for initial version.

    c("kitty_server.ex")
    > [KittyServer, KittyServer.Cat]

    pid = KittyServer.start_link()                                           
    cat1 = KittyServer.order_cat(pid, :carl, :brown, "loves to burn bridges")
    > %KittyServer.Cat{color: :brown, description: "loves to burn bridges",
    > name: :carl}

    KittyServer.return_cat(pid, cat1)                                        
    > :ok

    KittyServer.order_cat(pid, :jimmy, :orange, "cuddly")                    
    > %KittyServer.Cat{color: :brown, description: "loves to burn bridges",
    > name: :carl}

    KittyServer.order_cat(pid, :jimmy, :orange, "cuddly")                    
    > %KittyServer.Cat{color: :orange, description: "cuddly", name: :jimmy}

    KittyServer.return_cat(pid, cat1)                    
    > :ok

    KittyServer.close_shop(pid)                          
    > :carl was set free.
    > :ok
    
    KittyServer.close_shop(pid)
    > ** (ErlangError) Erlang error: :noproc
    >    kitty_server.ex:41: KittyServer.close_shop/1

## Extract Common Parts

Let's extract common parts of kitty shop and chef examples:

- setting up monitors
- timeouts
- receiving data
- main loop
- initialization

### Synchronous Calls

We can extract common parts of the 
synchronous "call" to `order_cat` and `close_shop`.

See `my_server.ex`, function call and modified `kitty_server.ex`.
Our Kitty Shop went from 86 lines to 65!

## Loop

Every process has a loop where messages are pattern matched.
We can extract it like so:

    def loop(module, state) do
        receive do
            msg -> module.handle(msg, state)
        end
        loop(...)
    end

But we also have "sync" and "async" messages. So we need to pattern match
on sync (let's name it a "call") and async (let's name it a "cast"):

    def loop(module, state) do
        receive do
            {:sync, pid, ref, msg} -> module.handle_call(msg, pid, ref, state)
            {:async, msg} -> module.handle_cast(msg, state)
        end
        loop(...)
    end

See:
- "call" and "cast" functions in `my_server` which now
  send appropriate messages
- "loop" function 
- `handle_` functions in `kitty_server.ex`

## Leaky Abstraction

There are some things in KittyShop that have no business being there:

- pid & ref terms that we use to "send" messages
- our `start_link` calls system "spawn" 
- our `init` calls `MyServer.loop` (which is private to MyServer)

Let's move it all out into MyServer:

1. Make `loop` private
2. Combine `{pid, ref}` into one tuple:

    def loop(module, state) do
        receive do
            {:sync, pid, ref, msg} -> module.handle_call(msg, {pid, ref}, state)
            {:async, msg} -> module.handle_cast(msg, state)
        end
        loop(...)
    end

3. Provide a `reply` function (MyServer):

    def reply({pid, ref}, reply) do
        send pid, {ref, reply}
    end

4. Make use of `reply` in `handle_call` (KittyServer)

5. Create (private) `init` in MyServer that starts the loop,
   and calls KittyServer init (which is now just a state transform)

6. Create `start_link` in MyServer that starts the loop,
   and make our KittyServer `start_link` call that.

7. Terminate now needs to exit explicitly (KittyServer)

Let's try it out:

    iex
    c("my_server.ex")
    c("kitty_server.ex")
    pid = KittyServer.start_link()
    > #PID<0.102.0>

    cat = KittyServer.order_cat(pid, :spiffy, :orange, "He's a happy camper!")
    > %KittyServer.Cat{color: :orange, description: "He's a happy camper!",
    > name: :spiffy}

    KittyServer.return_cat(pid, cat)
    > :ok
    
    KittyServer.close_shop(pid)
    > :spiffy was set free.
    > :ok

    Process.alive?(pid)
    > false

Our KittyServer is now only 62 lines of code, but more importantly:

- contains only Cat specific stuff
- no naked message passing
- no process spawning
- everything "generic" abstracted away into MyServer

What is MyServer?

## GenServer

MyServer is basically our own version of GenServer.  
GenServer is part of OTP.

OTP is set of libraries that extract many of the 
generic aspects of concurrent programming.

- if you have 100s of components, all reusing MyServer
  functionality, it increases understanding of the sytem
- less errors due to not handling complex edge cases
  (e.g. monitor, demonitor)
- testing code is easier, as we only need to
  provide old state, input and observe new state
- hundreds of years worth of testing and usage
  by community makes these abstractions battle-hardened

Let's throw out MyServer and rewrite our KittyServer with GenServer
instead. See `kitty_server.ex`:

    c("kitty_server.ex")
    {:ok, pid} = KittyServer.start_link()
    send pid, "Test"
    > Unexpected message: "Test"
    > "Test"

    cat = KittyServer.order_cat(pid, :spiffy, :white, "Very active!")
    > %KittyServer.Cat{color: :white, description: "Very active!", name: :spiffy}
    
    KittyServer.return_cat(pid, cat)
    > :ok

    cat = KittyServer.order_cat(pid, :jabby, :black, "Bites all the time")
    > %KittyServer.Cat{color: :white, description: "Very active!", name: :spiffy}
    
    KittyServer.return_cat(pid, cat)                                      
    > :ok

    > KittyServer.close_shop(pid)                                           
    > :spiffy was set free.
    > :ok

