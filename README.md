Reftable
========
Hoon H., Eonil

A key-value table which provides strict O(1) referencing time, but you cannot use arbitrary key.

Read by ref-key: strictly O(1).
Write by ref-key: strictly O(1). But you can only replace existing value.
Write can take up to O(n) due to internal array reallocation if it needs to increase capacity.

Take care about ref-key invalidation. If you use invalidated
ref-key, program will crash.

License
-------
MIT License.
