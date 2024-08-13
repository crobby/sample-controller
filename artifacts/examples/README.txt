1.  Install the CRD
2.  Start the controller
3.  Run makefoos.sh


makefoos.sh will create a pile of foo objects and will then proceed to update the IDs in each.

The controller, which will be syncing for each create/update, has its sync function set up so that on each call
it will attempt to lookup the foo by ID.  In an effort to make something targeted to our use case, we're really only concerned
with looking up the foo named example-foo.  It will start with IDs id1 and id2.  Each update cycle may change that to be id1 and id3,
or it will stay with id1 and id2.

If the Indexer is performing correctly, we will be able to fetch example-foo only by the IDs that currently exist on the object.
In those cases, nothing will be logged (unless you uncomment the klog lines that will show successes).

In our problem case, we are seeing the indexer return an object when we are querying by an ID that had previously been associated
with the object, but is no longer present on the object.  To detect any instances of that, we perform the cache lookup,
and then, if it was successful, we look at the returned object and make sure that the ID that we queried by is indeed
present on the object returned.  For cases where we detect this fail condition, we are logging an error.

A nice way to watch the foos get created and updated is:
watch -n 1 'kubectl get foo -o custom-columns=NAME:.metadata.name,IDs:.spec.IDs'