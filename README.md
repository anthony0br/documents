# documents
Documents is a rewrite of the project 'DocumentService'.

Aims:
1. Support the new type solver and utilise the latest type features (such as type functions) to improve developer experience
2. Be fully type checked in strict mode in the new type solver.
3. Fix all known bugs (e.g. 118 and 119).
4. Simplify the codebase and reduce maintenance requirements (e.g. 110, )
5. Redesign the API to reduce reliance on runtime errors, favour statically verified code, and fix convention issues such as lack of async suffixes.
6. Create a 'Simple Document' api for things that don't need (or can't use) session locking, rather than requiring users to open and close documents that aren't session locked.
7. Support my needs better: teleports, fast rejoining (via memorystore), and gradual to complete serialisation.
8. The new API must make it really, really hard to publish unintentional rollbacks (yield between read/write, as I once did), and should work with transform functions. In the future, if transactions are added to the library having all code in transforms would make the upgrade significantly easier.