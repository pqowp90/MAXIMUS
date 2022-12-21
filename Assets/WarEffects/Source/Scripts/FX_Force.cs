using UnityEngine;
using System.Collections;

namespace WarEffects
{
	public class FX_Force : MonoBehaviour
	{

		public float Force = 1000;
		public float Radius = 50;

		void Start ()
		{
			Vector3 explosionPos = transform.position;
			Collider[] colliders = Physics.OverlapSphere (explosionPos, Radius);
			foreach (Collider hit in colliders) {
				Rigidbody rb = hit.GetComponent<Rigidbody> ();
            
				if (rb != null)
					rb.AddExplosionForce (Force, explosionPos, Radius, 3.0F);
            
			}
		}

	}
}
