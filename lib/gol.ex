defmodule Gol do
  use Application.Behaviour

  # See http://elixir-lang.org/docs/stable/Application.Behaviour.html
  # for more information on OTP Applications
  def start(_type, _args) do
    Gol.Supervisor.start_link
  end

  def do_sth() do
    IO.write "Starting agents"
    agents = Enum.map(1..10000, &my_start_agent/1)
    IO.puts " done"
    

    IO.write "Setting neighbours for #{length agents} agents"
    set_neighbours(agents)
    IO.puts " done"
    
    Enum.at(agents, 3021) <- {:make_alive}
    Enum.at(agents, 3022) <- {:make_alive}
    Enum.at(agents, 3023) <- {:make_alive}
    

    Enum.at(agents, 1618) <- {:make_alive}
    Enum.at(agents, 1619) <- {:make_alive}
    Enum.at(agents, 1718) <- {:make_alive}
    Enum.at(agents, 1719) <- {:make_alive}


    Enum.at(agents, 1113) <- {:make_alive}
    Enum.at(agents, 1213) <- {:make_alive}
    Enum.at(agents, 1313) <- {:make_alive}
    Enum.at(agents, 1211) <- {:make_alive}    
    Enum.at(agents, 1312) <- {:make_alive}    

    IO.puts "Starting simulation"
    Enum.each(0..20, fn(i) -> send_and_collect(agents) end)
    IO.puts " done"
    
  end

  def set_neighbours(agents) do
    Enum.each(0..9999, fn(i) -> set_neighbours_for_agent(Enum.at(agents, i), seq_to_position(i), agents) end)
  end

  def set_neighbours_for_agent(agent, pos, agents) do
    neighbor_coords_for_agent = neighbor_coords((elem pos, 0), (elem pos, 1))
    seq_numbers = Enum.map(neighbor_coords_for_agent, &position_to_seq/1) 
    neighbour_agents = Enum.map(seq_numbers, fn(x) -> Enum.at(agents,x) end)  

    agent <- {:neighbours, Enum.filter(neighbour_agents, fn(a) -> a != nil end)}
  end

  def send_and_collect(agents) do
    Enum.each(agents, fn(a) -> a <- {:recalculate, self} end)
    wait_for_all(agents)
    IO.puts "--------------"
    Enum.each(agents, fn(a) -> a <- {:next_generation} end)
    Enum.each(agents, fn(a) -> a <- {:report, self} end)
  end

  defp wait_for_all(agents) do
    Enum.each(agents, fn(a) -> wait_for_recalculate() end)
  end

  defp wait_for_recalculate() do
    receive do
      other -> other
    end
  end

  defp my_start_agent(seq_number) do
   pid = Gol.Cell.start_agent(seq_to_position(seq_number))
   pid
 end

 defp seq_to_position(seq) do
  { div(seq,100), rem(seq,100) }
end

defp position_to_seq(pos) do
  Enum.at(pos,0) * 100 + Enum.at(pos,1)
end

def neighbor_coords(x, y) do
  [[x-1, y-1], [x, y-1], [x+1, y-1],
  [x-1, y],             [x+1, y],
  [x-1, y+1], [x, y+1], [x+1, y+1]]
end

end
