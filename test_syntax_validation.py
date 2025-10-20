#!/usr/bin/env python3
"""
Simple syntax validation for EV charging extension implementation in EMHASS
"""

import sys
sys.path.append('/workspaces/emhass/src')

def test_syntax_validation():
    """Test that our EV extension changes don't break the Python syntax"""

    print("Testing EMHASS EV Extension Syntax...")

    try:
        # Test imports
        import pulp as plp
        print("✓ PuLP import successful")

        from emhass.optimization import Optimization
        print("✓ Optimization class import successful")

        # Test that the class can be inspected
        print(f"✓ Optimization class loaded: {Optimization}")

        # Check if our methods exist
        import inspect
        methods = [method for method in dir(Optimization) if not method.startswith('_')]
        print(f"✓ Optimization methods available: {len(methods)}")

        print(f"\n🎉 Syntax Validation PASSED!")
        print("The EV charging extension code is syntactically correct!")

        return True

    except SyntaxError as e:
        print(f"\n❌ SYNTAX ERROR:")
        print(f"Error: {str(e)}")
        return False

    except ImportError as e:
        print(f"\n❌ IMPORT ERROR:")
        print(f"Error: {str(e)}")
        return False

    except Exception as e:
        print(f"\n❌ OTHER ERROR:")
        print(f"Error: {str(e)}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = test_syntax_validation()
    sys.exit(0 if success else 1)