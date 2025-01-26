# To-do List:

1. Refactor Wick's state machine solution. Horizontal movement should be moved into a component. It'll make handling knockback easier.
   - Currently there is an issue when attacking forward in air, where the knockback is negligable because it tries to set velocity to zero when you aren't moving.