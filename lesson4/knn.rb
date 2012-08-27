class Knn
  def initialize
    @data = []
    @id_to_position = {}
    @position_to_id = {}
  end

  def add_instance(instance_data, id)
    @data << instance_data
    position = @data.length - 1
    @id_to_position[id] = position
    @position_to_id[position] = id
  end

  def get_instance_for_id(id)
    @data[@id_to_position[id]]
  end

  def find_nearest_neighbors(unknown_instance, k, ignore_duplicates = false)
    nearest_neighbors = []

    @data.each_with_index do |instance, position|
      distance = calculate_distance(instance, unknown_instance)
      next if distance == 0.0 && ignore_duplicates

      if nearest_neighbors.length < k
        nearest_neighbors << [distance, position]
        nearest_neighbors = sort_neighbors(nearest_neighbors) if nearest_neighbors.length == k
      else
        max_distance = nearest_neighbors.last.first
        if (distance < max_distance)
          nearest_neighbors[nearest_neighbors.length - 1] = [distance, position]
          nearest_neighbors = sort_neighbors(nearest_neighbors)
        end
      end
    end

    sort_neighbors(nearest_neighbors).map do |neighbor|
      distance, position = neighbor
      [@position_to_id[position], distance]
    end
  end

  def calculate_distance(instance1, instance2)
    one_position = 0
    two_position = 0

    current_one = instance1[one_position]
    current_two = instance2[two_position]

    total_distance = 0.0

    while (one_position < instance2.length || two_position < instance2.length)
      index1, value1 = current_one
      index2, value2 = current_two
      index1 ||= index2
      index2 ||= index1
      value1 ||= 0
      value2 ||= 0

      if index1 == index2
        total_distance += (value1 - value2) ** 2
        one_position += 1
        two_position += 1
        current_one = instance1[one_position]
        current_two = instance2[two_position]
      elsif index1 < index2
        total_distance += value1 ** 2
        one_position += 1
        current_one = instance1[one_position]
      else
        total_distance += value2 ** 2
        two_position += 1
        current_two = instance2[two_position]
      end
    end

    return Math.sqrt(total_distance)
  end

  def sort_neighbors(neighbors)
    neighbors.sort {|a, b| a[0] <=> b[0]}
  end
end
