## Associated with [this Stack Overflow question](https://stackoverflow.com/q/69383881/5513562)

Reproduction of crash in diffable data source in UICollectionView:

> Assertion failure in -[NSDiffableDataSourceSectionSnapshot snapshotOfParentItem:includingParentItem:], NSDiffableDataSourceSectionSnapshot.m:330

> Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'Invalid parameter not satisfying: index != NSNotFound'

The sample app consists of just one screen, [`List`](diffable-experiments/List.swift) which uses a `UICollectionView` with a diffable data source. It is configured in such a way that the app unexpectedly crashes when reordering cells in one section followed by cells in another section.

Filed as FB9662195.
