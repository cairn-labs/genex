defmodule Genex.Operators.Crossover do
  alias Genex.Chromosome
  @moduledoc """
  Implementation of several popular crossover methods.

  Crossover is analagous to reproduction or biological crossover. Genex utilizes pairs of chromosomes to create offspring from the genetic material of parent chromosomes. Crossover happens with some probability `P(c)`. Typically this is a high probability.

  The probability of crossover or `crossover_rate` as it is called in our case, determines the number of parents selected to breed for the next generation. See more on this in the `Selection` documentation.

  Crossover operators are generic. As with any optimization problem, no single method will be perfect. Genex offers a variety of crossover operators to experiment with; however, you may find that you need to write your own to fit your specific use case. You can do this by overriding the `crossover` method.

  Each time a crossover takes place, 2 new children are created. These children then populate the `children` field of the `Population` struct before they are merged into the new population.
  """

  @doc """
  Performs single point crossover.

  This will swap a slice of genes from each chromosome, producing 2 new chromosomes.

  Returns `%Chromosome{}`.

  # Parameters
    - `p1`: Parent One.
    - `p2`: Parent Two.
  """
  @spec single_point(Chromosome.t(), Chromosome.t()) :: Chromosome.t()
  def single_point(p1, p2) do
    chromosome_length = p1.size
    point = :rand.uniform(chromosome_length)
    genes = Enum.slice(p1.genes, 0..point) ++ Enum.slice(p2.genes, point+1..chromosome_length-1)
    %Chromosome{genes: genes, size: p1.size}
  end

  @doc """
  Performs two-point crossover.

  This will swap multiple slices of genes from each chromosome, producing 2 new chromosomes.

  Returns `%Chromosome{}`.

  # Parameters
    - `p1`: Parent One.
    - `p2`: Parent Two.
  """
  @spec two_point(Chromosome.t(), Chromosome.t()) :: Chromosome.t()
  def two_point(p1, p2) do
    chromosome_length = p1.size
    a = :rand.uniform(chromosome_length-1)
    b = :rand.uniform(chromosome_length-2)
    point1 = if b >= a do a else b end
    point2 = if b >= a do b+1 else a end
    slice1 = Enum.slice(p1.genes, 0..point1)
    slice2 = Enum.slice(p2.genes, point1+1..point2)
    slice3 = Enum.slice(p1.genes, point2+1..chromosome_length-1)
    genes = slice1 ++ slice2 ++ slice3
    %Chromosome{genes: genes, size: p1.size}
  end

  @doc """
  Performs uniform crossover.

  This will swap random genes from each chromosome according to some specified rate, producing 2 new chrmosomes.

  Returns `Chromosome`.

  # Parameters
    - `p1`: Parent One.
    - `p2`: Parent Two.
    - `rate`: `Float` between 0 and 1 representing rates to swap genes.
  """
  @spec uniform(Chromosome.t(), Chromosome.t(), float()) :: Chromosome.t()
  def uniform(p1, p2, rate) do
    genes =
      p1.genes
      |> Enum.zip(p2.genes)
      |> Enum.map(fn {x, y} -> if :rand.uniform < rate do x else y end end)
    %Chromosome{genes: genes, size: p1.size}
  end

  @doc """
  Performs a blend crossover.

  This will blend genes according to some alpha between 0 and 1. If alpha=.5, the resulting chromosomes will be identical to one another.

  Returns `Chromosome`.

  # Parameters
    - `p1`: Parent one.
    - `p2`: Parent two.
    - `alpha`: `Float` between 0 and 1 representing percentage of each parent to blend into children.
  """
  @spec blend(Chromosome.t(), Chromosome.t(), float()) :: Chromosome.t()
  def blend(p1, p2, alpha) do
    genes =
      p1.genes
      |> Enum.zip(p2.genes)
      |> Enum.map(fn {x, y} -> alpha*x + (1-alpha)*y end)
    %Chromosome{genes: genes, size: p1.size}
  end

  @doc """
  Performs a simulated binary crossover.

  Returns `Chromosome`.

  # Parameters
    - `p1`: Parent one.
    - `p2`: Parent two.
    - `eta`: `Float`
  """
  @spec simulated_binary(Chromosome.t(), Chromosome.t(), number()) :: Chromosome.t()
  def simulated_binary(p1, p2, eta) do
    genes =
      p1.genes
      |> Enum.zip(p2.genes)
      |> Enum.map(
          fn {x, y} ->
            rand = :rand.uniform()
            beta = if rand <= 0.5 do 2 * rand else 1/(2*(1-rand)) end
            beta = :math.pow(beta, (1/eta+1))
            0.5 * (((1 + beta) * x) + ((1-beta) * y))
          end
        )
    %Chromosome{genes: genes, size: p1.size}
  end

  @doc """
  Performs a messy single point crossover.

  This crossover disregards the length of the chromosome and will often arbitrarily increase or decrease it's size.

  Returns `Chromosome`.

  # Parameters
    - `p1`: Parent one.
    - `p2`: Parent two.
  """
  @spec messy_single_point(Chromosome.t(), Chromosome.t()) :: Chromosome.t()
  def messy_single_point(p1, p2) do
    chromosome_length = length(p1.genes)
    point = if chromosome_length == 0 do 0 else :rand.uniform(chromosome_length) end
    slice1 = Enum.slice(p1.genes, point..chromosome_length)
    slice2 = Enum.slice(p2.genes, point..chromosome_length)
    genes = slice1 ++ slice2
    %Chromosome{genes: genes, size: length(genes)}
  end
end
