# To-do List:

1. Consider refactoring Wick's state machine solution. Horizontal movement should be moved into a component, the exact same code is repeated in a few places. The move state would exist solely to block other states from occuring during ground movement, and for animations, much like with idle.
   - Previously addressed issues from this have been resolved.
2. Refactor Wick's attacks so that it hits all enemies in the hitbox exactly once, instead of just hitting a single time.
   - This can be done by keeping a list of enemies that had the hit processed, and ignoring them on future frames.
3. Update the HealthComponent to simplify damage(). Take the iframe conditional and just move that logic to its own function that gets called inside of damage() instead of duplicating code.
   - Add the clamping here too like you did in ResourceComponent.
   - IMPORTANT, ensure that the iframe timer doesn't trigger for self-harm like losing light? TEST TEST TEST
4. Add a light behind Orbi, and probably Sludge, to make it easier to see them in the scene. Consider light purple, blue, or pink?
5. Continue to improve knockback. It still  isn't perfect. Look at Sludge, try to see how you can improve the feel. It works for now though.
6. Determine a way to make the player look hurt from self-damage, without interupting animation. This is for light-depletion based damage.
7. Consider adding a "resource overflow" like temp hp, if a player has full light and gets more...
8. NEXT THING -- TEST SCENARIO WHERE LIGHT is 5 plus, for healing more than 1 for example.
   -- Also test grabbing two smaller motes in rapid succession as well!
   -- FIGURE OUT WHY HEALING AT HIGH VALUES IS WRONG. For now, no heals larger than 3! Spawn extra motes!