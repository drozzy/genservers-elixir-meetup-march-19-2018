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


