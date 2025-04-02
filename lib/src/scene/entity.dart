/// Represents a unique identifier for an entity within the ECS World.
///
/// In an ECS architecture, an entity is simply an ID that aggregates a set of
/// components. It does not hold data or logic itself.
typedef Entity = int;

/// A constant representing an invalid or null entity.
const Entity nullEntity = -1;

// Note: The management of entities (creation, deletion) and the association
// between entities and components is handled by the World/EntityManager.
