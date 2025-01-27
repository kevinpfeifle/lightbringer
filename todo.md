# To-do List:

1. Consider refactoring Wick's state machine solution. Horizontal movement should be moved into a component, the exact same code is repeated in a few places. The move state would exist solely to block other states from occuring during ground movement, and for animations, much like with idle.
   - Previously addressed issues from this have been resolved.