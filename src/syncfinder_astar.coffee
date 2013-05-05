Heap = require "./heap"

openList = new Heap()

startLoc = 0

endLoc = 0

grid = null

locToClosed = null

locToOpen = null

locToG = null

locToH = null

locToF = null

locToParent = null

SQRT2 = Math.SQRT2

# Manhattan distance.
heuristic = (dx, dy) ->
  return dx + dy

# Backtrace according to the parent records and return the path.
# (including both start and end nodes)
# @param {uint} node End node
# @return the path array
backtrace = (node) ->
  path = []
  path.push(node)
  while (locToParent[node])
    node = locToParent[node]
    path.unshift(node)
  return path

syncfinder_astar =

  findPath : (startX, startY, endX, endY, theGrid) ->
    startLoc = startX << 16 | startY
    endLoc = endX << 16 | endY
    grid = theGrid
    locToClosed = {}
    locToOpen = {}
    locToG = {}
    locToF = {}
    locToH = {}
    locToParent = {}


    # set the `g` and `f` value of the start node to be 0
    locToG[startLoc] = 0
    locToF[startLoc] = 0

    openList.reset(locToF)

    openList.push(startLoc)
    locToOpen[startLoc] = true

    while(openList.isNotEmpty())
      # pop the position of node which has the minimum `f` value.
      node = openList.pop()
      locToClosed[node] = true

      if node is endLoc
        return backtrace(node)

      # get neighbors of the current node
      nodeX = node >>> 16
      nodeY = node & 0xffff
      neighbors = grid.getNeighbors(nodeX , nodeY)

      for i in [0..neighbors.length]
        neighbor = neighbors[i]
        continue if locToClosed[neighbor]

        x = neighbor >>> 16
        y = neighbor & 0xffff

        # get the distance between current node and the neighbor
        # and calculate the next g score
        ng = locToG[node] + (if x is nodeX or y is nodeY then 1 else SQRT2)


        # check if the neighbor has not been inspected yet, or
        # can be reached with smaller cost from the current node
        if not locToOpen[neighbor] or ng < locToG[neighbor]
          locToG[neighbor] = ng
          locToH[neighbor] = locToH[neighbor] or  heuristic(Math.abs(x - endX) , Math.abs(y - endY))
          locToF[neighbor] = locToG[neighbor] + locToH[neighbor]
          neighborNode = x << 16 | y
          locToParent[neighborNode] = node

          if not locToOpen[neighbor]
            openList.push(neighborNode)
            locToOpen[neighbor] = true
          else
            # the neighbor can be reached with smaller cost.
            # Since its f value has been updated, we have to
            # update its position in the open list
            openList.updateItem(neighborNode)

    # fail to find the path
    return null



module.exports = syncfinder_astar




