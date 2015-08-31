using UnityEngine;
using System.Collections;

public class BuildMap : MonoBehaviour {
	public ArrayList tileCoordinates;
	public Transform tilePrefab;
	// Use this for initialization
	void Start () {
		for (int i = 0; i < 10; i++) {
			Object tile = Instantiate (tilePrefab, new Vector3 (0, 0, i * 2), Quaternion.identity);
			tile.name = "Tile " + i.ToString ();
		}
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
