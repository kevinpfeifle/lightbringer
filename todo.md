# To-do List:

1. Refactor Wick's state machine solution. Horizontal movement should be moved into a component. It'll make handling knockback easier.
   - Currently there is an issue when attacking forward in air, where the knockback is negligable because it tries to set velocity to zero when you aren't moving.
2. Figure out what is making Wick's bounce jump inconsistent. *Requires more testing, but might be fixed*
3. Figure out in-air knockback for enemies. The 4 directional knockback feels bad.