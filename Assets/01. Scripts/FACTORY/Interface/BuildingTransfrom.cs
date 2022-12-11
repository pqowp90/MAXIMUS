using UnityEngine;

public interface BuildingTransfrom
{

	void SetTransform(int _rotation, Vector2Int _pos);
	public void AddToManager(Vector2Int curPos, int curRotation);
}