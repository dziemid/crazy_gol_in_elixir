defmodule Gol.Cell do
  
  def start_agent(position) do
    spawn (fn ->
                     #isAlive, position, neighbours, responses_count, live_neighbours, recalculate pid  
                     handle_message({:dead, position, [], 0, 0, nil})
                   end)
  end

  def handle_message(state) do
    receive do
      { :report, pid } -> handle_message(handle_hello(state, pid))
      { :neighbours, neighbours } -> handle_message(set_neighbours(state, neighbours))
      { :kill }       -> handle_message(kill(state))
      { :make_alive } -> handle_message(make_alive(state))
      { :next_generation } -> handle_message(next_generation(state))
      { :cell_state, pid} -> handle_message(cell_state(state, pid)) 
      { :recalculate, pid } -> handle_message(recalculate(state, pid)) 
      { :cell_state_info, neighbour_state} -> handle_message(respone_from_neighbour(state, neighbour_state)) 
    end
  end

  defp next_generation(state) do
    my_state = cell_state(state)
    alive = alive_count(state)
    case {my_state, alive} do
      {whatever, 3}     -> make_alive(state)
      {:alive, 2}       -> state
      {:dead, whatever} -> state
      {:alive, whatever} -> kill(state)
    end
  end

  defp respone_from_neighbour(state, neighbour_state) do
    #IO.puts "got response"
    new_state = case neighbour_state do
      :dead  -> set_neighbours_info(state, responses_received(state)+1, alive_count(state))
      :alive  -> set_neighbours_info(state, responses_received(state)+1, alive_count(state)+1)
    end
    #IO.puts "got response and figured out what to do"
    if responses_received(new_state) == length(get_neighbours(new_state)), do: respond_to_pid(new_state) <- { :recalculating_done }
    new_state
  end

  defp recalculate(state, pid) do
    
    new_state = reset_neighbours_info(state)
    new_state_2 = will_send_response_to(new_state, pid)
    #IO.puts "recalculate #{get_neighbours(new_state_2)}"
    Enum.each(get_neighbours(new_state_2), fn(n)-> ask_neighbour(n) end)
    new_state_2
  end

  defp ask_neighbour(n) do
    #IO.puts "asking "
    n <- { :cell_state, self} 
  end

  defp will_send_response_to(state, pid) do
    set_elem state, 5, pid
  end

  defp respond_to_pid(state) do
    elem state, 5
  end

  defp cell_state(state, pid) do
    pid <- {:cell_state_info, cell_state(state) }
    state
  end

  defp handle_hello(state, pid) do
    my_state = cell_state(state)
    case my_state do
      :alive     -> IO.write "#{cell_position_string(state)}"
      :dead      -> 
      end
      
      state
    end

    defp set_neighbours(state, neighbours) do
    #IO.puts "setting neighbours"
    set_elem state, 2, neighbours
  end

  def get_neighbours(state) do
    elem state, 2
  end

  defp kill(state) do
    set_elem state, 0, :dead
  end

  defp make_alive(state) do
    set_elem state, 0, :alive
  end

  defp responses_received(state) do
    elem state, 3
  end

  defp alive_count(state) do
    elem state, 4
  end

  defp set_neighbours_info(state, responses_count, live_neighbours) do
    (set_elem (set_elem state, 3, responses_count), 4, live_neighbours)
  end

  defp reset_neighbours_info(state) do
    set_neighbours_info(state, 0 ,0)
  end

  defp cell_state(state) do
    elem state, 0
  end

  defp cell_position(state) do
    elem state, 1
  end

  def cell_position_string(state) do
    pos = cell_position(state)
    "(#{elem pos, 0}, #{elem pos, 1})"
  end

end