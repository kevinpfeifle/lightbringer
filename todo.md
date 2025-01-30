# To-do List:

1. Consider refactoring Wick's state machine solution. Horizontal movement should be moved into a component, the exact same code is repeated in a few places. The move state would exist solely to block other states from occuring during ground movement, and for animations, much like with idle.
   - Previously addressed issues from this have been resolved.
2. Refactor Wick's attacks so that it hits all enemies in the hitbox exactly once, instead of just hitting a single time.
   - This can be done by keeping a list of enemies that had the hit processed, and ignoring them on future frames.
3. Update the HealthComponent to simplify damage(). Take the iframe conditional and just move that logic to its own function that gets called inside of damage() instead of duplicating code.
   - Add the clamping here too like you did in ResourceComponent.
   - IMPORTANT, ensure that the iframe timer doesn't trigger for self-harm like losing light? TEST TEST TEST
4. Continue to improve knockback. It still  isn't perfect. Look at Sludge, try to see how you can improve the feel. It works for now though.
5. Determine a way to make the player look hurt from self-damage, without interupting animation. This is for light-depletion based damage.
6. Consider adding a "resource overflow" like temp hp, if a player has full light and gets more...
7. NEXT THING -- TEST SCENARIO WHERE LIGHT is 5 plus, for healing more than 1 for example.
   -- Also test grabbing two smaller motes in rapid succession as well!
   -- FIGURE OUT WHY HEALING AT HIGH VALUES IS WRONG. For now, no heals larger than 3! Spawn extra motes!
8. Time allowing... make Wick's light based on his health. Greater starting light, less light as you lose health.
9. Implement a stunned effect when Wick produces light in close range to a non-boss enemy.
10. Create components for the pathfinding logic in Orbi. It already got reused in Lightbug, it could be better written to extend to any flying enemy that wanders/chases.
11. If you have time -- make it so enemies kill lightbugs on contact, Orbis chase lightbugs if Wick isn't in range.