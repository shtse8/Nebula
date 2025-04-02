// Components are primarily data containers in an ECS architecture.
// Logic operating on this data resides in Systems.

/// Base class (marker) for all components in the ECS.
///
/// Components are simple data holders. Systems query for entities
/// possessing specific components and operate on their data.
class Component {
  // Components generally should not hold references back to their entity in pure ECS.
  // The World/EntityManager manages the relationship.

  /// Whether this component (and potentially the entity) is considered active
  /// by systems that care about activation state.
  /// Not all systems might check this.
  bool isEnabled = true;

  // Lifecycle methods like onAttach, onDetach, update are typically handled by Systems,
  // not the component itself.

  // Concrete components will extend this and add data fields.
  // Example:
  // class Position extends Component {
  //   double x = 0.0;
  //   double y = 0.0;
  // }
}
