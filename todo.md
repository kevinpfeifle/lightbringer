# To-do List:

1. Consider refactoring Wick's state machine solution. Horizontal movement should be moved into a component, the exact same code is repeated in a few places. The move state would exist solely to block other states from occuring during ground movement, and for animations, much like with idle.
   - Previously addressed issues from this have been resolved.
2. Refactor Wick's attacks so that it hits all enemies in the hitbox exactly once, instead of just hitting a single time.
   - This can be done by keeping a list of enemies that had the hit processed, and ignoring them on future frames.
3. Update the HealthComponent to simplify damage(). Take the iframe conditional and just move that logic to its own function that gets called inside of damage() instead of duplicating code.
4. Add a light behind Orbi, and probably Sludge, to make it easier to see them in the scene. Consider light purple, blue, or pink?