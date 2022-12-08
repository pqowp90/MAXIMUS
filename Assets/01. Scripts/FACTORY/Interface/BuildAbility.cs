
using UnityEngine;

public interface BuildAbility<T>
{
	void Build(Vector2Int _pos, int _rotation, T building);
	void Destroy(T building);
	void Use();
}
