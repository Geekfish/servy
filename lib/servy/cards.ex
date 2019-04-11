defmodule HandOfCards do
  def deal do
    ranks = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
    suits = ["♣", "♦", "♥", "♠"]
    deck = for rank <- ranks, suit <- suits, do: {rank, suit}
    deck |> Enum.shuffle() |> Enum.chunk_every(13)
  end
end
