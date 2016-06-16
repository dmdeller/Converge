Release Notes
=============

1.1.0
-----

### Additions

- Added a method on ConvergeRecord `+ mergeChangesFromProvider:withQuery:recursive:context:error:` for merging a single record (rather than a collection of records). Saves you from needing to wrap your record in an array when you only have one. `7a1620`
- Ruby on Rails prefers to receive submitted JSON data wrapped in an object with a single attribute, named with the entity name, at the root. Converge has always done this by default. However, some other kinds of servers prefer to receive the data 'unwrapped', with just the entity attributes at the root. This can now be accomplished by overriding `+ shouldWrapRequestBody` and returning `NO`. `56c8a0`
- Before returning an error in any of its `failureBlock`s, Converge now consults the new method `+ errorForOperation:error:`. You can override this method if you would like Converge to return a different sort of error, depending on the situation. `9a0aa1`
- The new method `+ shouldAlwaysCreateNew` (default `NO`) on your records allows you to specify that Converge should not attempt to merge the provider record with an existing record in your local store. `3eb660`, `8557b1`, `a0c9f1`
- Converge now supports provider data that does not contain any kind of unique primary key (or perhaps it does, but you want to pretend it doesn't for reasons). In order to make use of this, override `+ IDAttributeName` to return `nil`, and override `+ shouldAlwaysCreateNew` to return `YES`. `3eb660`, `8557b1`, `a0c9f1`

### Changes

- `ConvergeClient`'s `context` is no longer `readonly`. You are now allowed to change it after instantiation. `a05803`
- When merging attributes for the root object in the provider data, Converge uses the HTTP query parameters (if available) to determine the scope of the provider's data. For example, if the request was `/users?name=David`, and your entity has a `name` attribute, Converge assumes the request only involved users whose `name` is equal to `David`. This is still the case, however, Converge now only uses this logic for objects at the root of the provider data; it used to extend this HTTP query parameter logic when merging related records as well, which it no longer does. This was necessary to resolve unintended behaviour when a related entity had the same attribute name as the entity belonging to the root object. `f3f740`

### Fixes

- When the provider ID attribute name has not been mapped, Converge now assumes it is the same as the local ID attribute name, instead of the string `@"id"`. `dcb640`
- The Readme advises that you delete the file at `+ timestampsFileURL` when the Core Data store changes significantly. However, this method was not public, making this advice impossible to follow (until now). `2aa8f0`
- In many cases, timestamp tracking was not working at all. `095db2`
- Converge now uses the Core Data entity name, rather than the class name, when guessing URLs. The entity name is considered to be more representative of your intent, whereas the class name is an irrelevant implementation detail that Converge should not care about. `9fd259`
- When merging data after a successful create/update, Converge incorrectly used the local ID attribute name, instead of the provider ID attribute name. `1e55d4`
- Converge was not properly serialising requests as JSON. `a74c39`, `50e72f`
- Merging methods were using the wrong `NSError` domain. `bbbb9d`
- Attributes and relationships that had a value in the local store, then were changed to `null` in provider data, were not properly being set to `nil` upon merging. `f4d255`

1.0.0
-----

Initial public release