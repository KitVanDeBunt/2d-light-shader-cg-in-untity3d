using UnityEngine;
using System.Collections;

public class scriptMove : MonoBehaviour {
	public int speed = 30;
	public int rotateSpeed = 3;

	int up = 0;
	int down = 0;
	int left = 0;
	int right = 0;
	float upDown = 0;
	float leftRight = 0;

	float Rspeed = 0;
	void FixedUpdate () {
		
		leftRight = Input.GetAxis("Horizontal");
		upDown = Input.GetAxis("Vertical");
		
		rigidbody2D.AddForce(new Vector2(leftRight*speed,upDown*speed));
    }
}
